using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using System.Numerics;

namespace ImageResizer.Plugins.LicenseVerifier
{
    internal class RSADecryptPublic
    {
        public RSADecryptPublic(BigInteger modulus, BigInteger exponent)
        {
            Modulus = modulus;
            Exponent = exponent;
            BlockSize = Modulus.ToByteArray().Length;
        }
        public BigInteger Modulus { get; private set; }
        public BigInteger Exponent { get; private set; }
        public int BlockSize { get; private set; }
        public byte[] DecryptPublic(byte[] input_bytes)
        {
            if (input_bytes.Length > BlockSize)
            {
                throw new ArgumentOutOfRangeException("input", "input too large for RSA cipher.");
            }
            var input = new BigInteger(input_bytes.Reverse().Concat(Enumerable.Repeat<byte>(0,1)).ToArray()); //Add a zero to prevent interpretation as twos-complement

            if (input.CompareTo(Modulus) >= 0)
            {
                throw new ArgumentOutOfRangeException("input", "input too large for RSA cipher.");
            }
            int signature_padding  = 0; //1
            return BigInteger.ModPow(input, Exponent, Modulus).ToByteArray().Skip(signature_padding).Reverse().SkipWhile(v => v != 0).Skip(1 + signature_padding).ToArray();
        }

    }

    internal class Ver{
        public int Major{get; private set;}
        public int Minor{get; private set;}
        public int Patch{get; private set;}
        public Ver(int major, int minor, int patch){
            this.Major = major;
            this.Minor = minor;
            this.Patch = patch;
        }
        public static Ver TryParse(string text){
            if (string.IsNullOrEmpty(text)){
                return null;
            }
            int major = 0, minor = 0, patch = 0;
            int dot = text.IndexOf('.');
            if (dot < 0) dot = text.Length;
            if (!int.TryParse(text.Substring(0,dot), out major)){
                return null; 
            }
            int nextDot = text.IndexOf('.', dot + 1);
            if (nextDot < 0) nextDot = text.Length;

            if (nextDot > dot + 1){
                //Is Subtring index or length?
                if (!int.TryParse(text.Substring(dot + 1,nextDot), out minor)){
                    return null; 
                }
                if (nextDot < text.Length - 1){
                    if (!int.TryParse(text.Substring(nextDot,text.Length), out patch)){
                        return null; 
                    }
                }
            }
            return new Ver(major, minor, patch);;
        }
    }

    internal class LicenseDetails
    {
        //For human use (only, at this point)
        public string Locator{get; private set; }
        public string Status{get; private set;}
        public string OwnerName { get; private set; }
        public string Restrictions { get; private set; }

        public string Kind { get; private set; }
        public string SKU { get; private set; }
        public string Product { get; private set; }

        public int TotalCores { get; private set;}
        public int Servers { get; private set;}

        // If true, make license details available over HTTP
        public bool IsPublic{get; private set;}

        // If true, a perpetual license to all pre-expires builds 
        public DateTime PerpetualLicenseToBuildsBefore{get; private set;}


        /// The domain name that this license will cover
        public string Domain { get; private set; }

        /// When this license becomes valid
        public DateTime Issued { get; private set; }

        /// When this license expires
        public DateTime Expires { get; private set; }

        /// Feature codes enabled by this 
        public IList<string> Features { get; private set; }

        public LicenseDetails(string plaintext)
        {
            Expires = DateTime.MaxValue;
            Issued = DateTime.MinValue;
            string[] lines = plaintext.Split('\n');
            foreach (string l in lines)
            {
                int colon = l.IndexOf(':');
                if (colon < 1) continue;
                string key = l.Substring(0, colon).Trim().ToLowerInvariant();
                string value = l.Substring(colon + 1).Trim();

                switch (key)
                {
                    case "totalcores": TotalCores = int.Parse(value); break;
                    case "servers": Servers = int.Parse(value); break;
                    case "ispublic": IsPublic = bool.Parse(value); break;
                    case "perpetuallicensetobuildsbefore": PerpetualLicenseToBuildsBefore = DateTime.Parse(value); break;
                    case "locator": Locator = value; break;
                    case "domain": Domain = value.Trim().ToLowerInvariant(); break;
                    case "owner": OwnerName = value; break;
                    case "sku": SKU = value; break;
                    case "product": Product = value; break;
                    case "status": Status = value; break;
                    case "kind": Kind = value; break;
                    case "restrictions": Restrictions = value; break;
                    case "issued": Issued = DateTime.Parse(value); break;
                    case "expires": Expires = DateTime.Parse(value); break;
                    case "features":
                        Features = value.Split(new char[] { ' ', ',' }, StringSplitOptions.RemoveEmptyEntries).Select(s => s.Trim()).ToList();
                        break;
                }
            }
            if (Issued == DateTime.MinValue || OwnerName == null || Features == null || Features.Count == 0)
            {
                throw new ArgumentOutOfRangeException("plaintext", "Invalid license; missing one or more of Issued, OwnerName, Features");
            }
        }
        public string ValidationError(){
            // Always required: OwnerName, Features, Issued


            // There must be one of the following restrictions:
            // Domain name
            // Expires date
            // MaxVersion
            // except for kickstarter lifetime licenses
            return null;
        }

        public override string ToString()
        {
            var sb = new StringBuilder();
            if (Kind != null){
                sb.AppendFormat("Kind: {}\n", Kind);
            } 
            if (OwnerName != null){
                sb.AppendFormat("OwnerName: {}\n", OwnerName);
            } 
            return sb.ToString();
            //return String.Format(
            //    "Domain: {0}\nOwnerName: {1}\nIssued: {2}\nExpires: {3} \nFeatures: {4} \n",
            //    Domain.Replace('\n', ' '), OwnerName.Replace('\n', ' '), Issued.ToString(), Expires.ToString(), String.Join(" ", Features));

        }

    }

    internal class LicenseBlob
    {
        public byte[] InfoUTF8 { get; set; }
        public string Info { get; set; }

        public LicenseDetails Details { get; private set;}
        public byte[] Signature { get; set; }

        public IEnumerable<string> Comments { get; set; }

        public static LicenseBlob Deserialize(string license)
        {
            var parts = license.Split(':').Select(s => s.Trim()).ToList();
            if (parts.Count < 2) throw new ArgumentException("Not enough segments in license key; failed to deserialize: \"" + license + "\"", "license");

            var b = new LicenseBlob();
            b.Signature = Convert.FromBase64String(parts[parts.Count - 1]);
            b.InfoUTF8 = Convert.FromBase64String(parts[parts.Count - 2]);
            b.Info = UTF8Encoding.UTF8.GetString(b.InfoUTF8);
            b.Comments = parts.Take(parts.Count - 2);
            b.Details = new LicenseDetails(b.Info);
            return b;
        }
    }

    internal class LicenseValidator
    {


        public bool Validate(LicenseBlob b, RSADecryptPublic p, StringBuilder  log)
        {
            var hash = new SHA512Managed().ComputeHash(b.InfoUTF8);
            var decrypted_bytes = p.DecryptPublic(b.Signature);
            var valid = hash.SequenceEqual(decrypted_bytes);

            if (log != null)
            {
                log.AppendLine("Using public modulus: " + p.Modulus.ToString());
                log.AppendLine("Using public exponent: " + p.Exponent.ToString());
                log.AppendLine("Encrypted bytes: " + BitConverter.ToString(b.Signature).ToLower().Replace("-", ""));
                log.AppendLine("Decrypted sha512: " + BitConverter.ToString(decrypted_bytes).ToLower().Replace("-", ""));
                log.AppendLine("Expected sha512: " + BitConverter.ToString(hash).ToLower().Replace("-", ""));
            }
            return valid;
        }

        static bool Test_Generic( StringBuilder log){
            if (log != null) log.AppendLine("Generic license decryption self-test");
            var exp = BigInteger.Parse("65537");
            var mod = BigInteger.Parse("28178177427582259905122756905913963624440517746414712044433894631438407111916149031583287058323879921298234454158166031934230083094710974550125942791690254427377300877691173542319534371793100994953897137837772694304619234054383162641475011138179669415510521009673718000682851222831185756777382795378538121010194881849505437499638792289283538921706236004391184253166867653735050981736002298838523242717690667046044130539971131293603078008447972889271580670305162199959939004819206804246872436611558871928921860176200657026263241409488257640191893499783065332541392967986495144643652353104461436623253327708136399114561");
            var license_str = "localhost:RG9tYWluOiBsb2NhbGhvc3QKT3duZXI6IEV2ZXJ5b25lCklzc3VlZDogMjAxNS0wMy0yOFQwOTozNjo1OVoKRmVhdHVyZXM6IFI0RWxpdGUgUjRDcmVhdGl2ZSBSNFBlcmZvcm1hbmNlCg==:h6D+kIXbF3qmvmW2gDpb+b4gdxBjnrkZLvSzXmEnqKAywNJNpTdFekpTOB4SwU14WbTeVyWwvFngHax7WuHBV+0WkQ5lDqKFaRW32vj8CJQeG8Wvnyj9PaNGaS/FpKhNjZbDEmh3qqirBp2NR0bpN4QbhP9NMy7+rOMo0nynAruwWvJKCnuf7mWWdb9a5uTZO9OUcSeS/tY8QaNeIhaCnhPe0Yx9qvOXe5nMnl10CR9ur+EtS54d1qzBGHqN/3oFhiB+xlqNELwz23qR4c8HxbTEyNarkG4CZx8CbbgJfHmPxAYGJTTBTPJ+cdah8MJR16Ta36cRZ2Buy8XYo/nf1g==";

            return Validate(license_str, mod, exp, log);
        }

        static bool Validate(string license_str, BigInteger mod, BigInteger exp, StringBuilder log){
            var blob = LicenseBlob.Deserialize(license_str);
            if (log != null) log.AppendLine("---------------------------------------------");
            if (log != null) log.AppendLine("Parsed info: " + blob.Info);
            if (log != null) log.AppendLine("Plaintext hash: " + BitConverter.ToString(new SHA512Managed().ComputeHash(blob.InfoUTF8)).ToLower().Replace("-", ""));
            

            var decryptor = new RSADecryptPublic(mod, exp);

            return new LicenseValidator().Validate(blob, decryptor, log);
        }

        static int Main(string[] args)
        {



            var modulus = args[0];
            var exponent = args[1];

            var mod = BigInteger.Parse(UTF8Encoding.UTF8.GetString(Convert.FromBase64String(modulus)));
            var exp = BigInteger.Parse(UTF8Encoding.UTF8.GetString(Convert.FromBase64String(exponent)));


            string license_str = null;

            using (var s = System.Console.OpenStandardInput())
            using (var sr = new StreamReader(s, System.Text.Encoding.UTF8))
            {
                license_str = sr.ReadToEnd();
            }

            bool debug = args.Length > 2 && args[2] == "-d";
            StringBuilder log = debug ? new StringBuilder() : null;
            

            int result = (debug && !Test_Generic(log)) ? 4 : 0;
            
            if (!Validate(license_str, mod, exp, log))
            {
                result =  2 ^ result;
            }
            if (log != null && result != 0) Console.WriteLine(log.ToString());
            return result;
        }
    }
}
