require "minitest/autorun"
require "imazen_licensing"
require_relative "support/license_test_base"
require "digest"

module ImazenLicensing
  class TestLicenseForms <  ImazenLicensing::LicenseTestBase

    def self.issued
      DateTime.parse('2017-04-21')
    end
    def issued
      DateTime.parse('2017-04-21')
    end

    def sha256_hex(v)
      Digest::SHA256.hexdigest v.to_s
    end 
    def sha32_dec(v)
      Digest::SHA256.digest(v.to_s)[0..4].unpack("L")[0].to_s
    end 

    REMOTE_LICENSES = {
      v4_elite_remote: {
        id: nil,
        owner: 'Acme Corp',
        features: ['R4Elite', 'R4Creative', 'R4Performance'],
        kind: 'v4-elite',
        issued: issued,
        is_public: true,
        must_be_fetched: true,
      },
      v4_domain_remote_subscription: {
        id: nil,
        owner: 'Acme Corp',
        domains: ['box.com', 'stamps.com'],
        features: ['R4Performance'],
        kind: 'v4-domain',
        issued: issued,
        expires: issued +  45, # add 45 days
        is_public: true,
        must_be_fetched: true,
      },
      hard_revocation: {
        id: nil,
        owner: 'Acme Corp',
        features: ['R_Elite', 'R_Creative', 'R_Performance'],
        product: "Enterprise-wide license",
        kind: 'site-wide',
        issued: issued,
        is_public: true,
        valid: false,
        message: 'Please contact support; the license was shared with an unauthorized party and has been revoked.'
      },
      hard_revocation_imageflow: {
          id: nil,
          owner: 'Acme Corp',
          features: ['Imageflow'],
          product: "Enterprise-wide license",
          kind: 'site-wide',
          issued: issued,
          is_public: true,
          valid: false,
          message: 'Please contact support; the license was shared with an unauthorized party and has been revoked.'
      },
      soft_revocation: {
        id: nil,
        owner: 'Acme Corp',
        features: ['R_Elite', 'R_Creative', 'R_Performance'],
        product: "OEM redistribtuion license",
        kind: 'oem',
        issued: issued,
        expires: issued +  45, # add 45 days
        is_public: true,
        must_be_fetched: true,
        subscription_expiration_date: issued,
        message: 'This license has been compromised; please contact Vendor Gamma for an updated license',
        restrictions: "Only for use within Vendor Gamma Prduct"
      },
      soft_revocation_imageflow: {
          id: nil,
          owner: 'Acme Corp',
          features: ['Imageflow'],
          product: "OEM redistribtuion license",
          kind: 'oem',
          issued: issued,
          expires: issued +  45, # add 45 days
          is_public: true,
          must_be_fetched: true,
          subscription_expiration_date: issued,
          message: 'This license has been compromised; please contact Vendor Gamma for an updated license',
          restrictions: "Only for use within Vendor Gamma Prduct"
      },
      perpetual: {
        id: nil,
        owner: 'Acme Corp',
        features: ['R_Elite', 'R_Creative', 'R_Performance'],
        product: "site-wide",
        kind: 'site-wide',
        issued: issued,
        is_public: true,
        must_be_fetched: true,
        subscription_expiration_date: issued,
        message: 'Your subscription has expired; please renew to access newer product releases.'
      }, 
      cancelled: {
        id: nil,
        owner: 'Acme Corp',
        features: ['R_Elite', 'R_Creative', 'R_Performance'],
        product: "site-wide",
        kind: 'site-wide',
        issued: issued,
        is_public: true,
        must_be_fetched: true,
        valid: false,
        message: 'Your subscription has lapsed; please renew to continue using product.'
      },
      cancelled_imageflow: {
          id: nil,
          owner: 'Acme Corp',
          features: ['Imageflow'],
          product: "site-wide",
          kind: 'site-wide',
          issued: issued,
          is_public: true,
          must_be_fetched: true,
          valid: false,
          message: 'Your subscription has lapsed; please renew to continue using product.'
      },
      site_wide: {
        id: nil,
        owner: 'Acme Corp',
        features: ['R_Elite', 'R_Creative', 'R_Performance'],
        product: "Enterprise-wide license",
        kind: 'site-wide',
        issued: issued,
        expires: issued +  45, # add 45 days
        is_public: true,
        must_be_fetched: true,
        manage_your_subscription: 'https://account.imazen.io',
        restrictions: "No resale of usage. Only for organizations with less than 500 employees."
      },
      site_wide_imageflow: {
          id: nil,
          owner: 'Acme Corp',
          features: ['Imageflow'],
          product: "Enterprise-wide Imageflow license",
          kind: 'site-wide',
          issued: issued,
          expires: issued +  45, # add 45 days
          imageflow_expires: issued + 45,
          is_public: true,
          must_be_fetched: true,
          manage_your_subscription: 'https://account.imazen.io',
          restrictions: "No resale of usage. Only for organizations with less than 500 employees."
      },
      oem: {
        id: nil,
        owner: 'Acme Corp',
        features: ['R_Elite', 'R_Creative', 'R_Performance'],
        product: "OEM redistribtuion license",
        kind: 'oem',
        issued: issued,
        expires: issued +  50, # add 50 days
        is_public: true,
        must_be_fetched: true,
        manage_your_subscription: 'https://account.imazen.io',
        restrictions: "Only for use within Vendor Gamma Prduct"
      }, 
      cores: {
        id: nil,
        owner: 'Acme Corp',
        features: ['R_Elite', 'R_Creative', 'R_Performance'],
        product: "Per-core license",
        kind: 'per-core',
        issued: issued,
        expires: issued +  50, # add 50 days
        is_public: true,
        must_be_fetched: true,
        max_servers: 4,
        total_cores: 16,
        manage_your_subscription: 'https://account.imazen.io',
      },
      per_core_2_domains: {
        id: nil,
        owner: 'Acme Corp',
        domains: ['acme.com', 'acmestaging.com'],
        features: ['R_Performance'],
        product: "Per Server | 2 Domains | Performance",
        kind: 'per-core-domain',
        issued: issued,
        expires: issued +  50, # add 50 days
        is_public: true,
        must_be_fetched: true,
        max_servers: 4,
        total_cores: 16,
        manage_your_subscription: 'https://account.imazen.io',
      },
      per_core_2_domains_imageflow: {
          id: nil,
          owner: 'Acme Corp',
          domains: ['acme.com', 'acmestaging.com'],
          features: ['Imageflow'],
          product: "Per Server | 2 Domains | Performance",
          kind: 'per-core-domain',
          issued: issued,
          expires: issued +  50, # add 50 days
          imageflow_expires: issued +  50, # add 50 days
          is_public: true,
          must_be_fetched: true,
          max_servers: 4,
          total_cores: 16,
          manage_your_subscription: 'https://account.imazen.io',
      },
      xml: {
        id: nil,
        owner: 'Acme Corp <>',
        domains: ['acme.com', 'acmestaging.com'],
        features: ['R_Performance'],
        product: "Per Server | 2 Domains | Performance",
        kind: 'per-core-domain',
        issued: issued,
        expires: issued +  50, # add 50 days
        is_public: true,
        must_be_fetched: true,
        max_servers: 4,
        total_cores: 16,
        manage_your_subscription: 'https://account.imazen.io',
      }
    }

    def id_license_for(name, remote)
      {
        kind: 'id',
        id: remote[:id],
        secret: "test#{sha256_hex(name)}",
        owner: remote[:owner],
        issued: issued,
        network_grace_minutes: 60 * 8,
        is_public: false,
      }
    end 

    def create_by_name(name)
      remote = REMOTE_LICENSES[name]
      remote[:id] = sha32_dec(name)
      id_license = id_license_for(name, remote)
      [id_license, remote]
    end 

    def get_all_licenses
      REMOTE_LICENSES.keys.map do |name|
        id, remote = create_by_name(name)
        {id_license: generate_for(id), 
          id: id[:id],
          secret: id[:secret], 
          remote_license: generate_for(remote),
          id_hash: id,
          id_plaintext: plaintext_for(id),
          remote_hash: remote,
          remote_plaintext: plaintext_for(remote)
        }
      end
    end

    def get_all_plaintext
      REMOTE_LICENSES.keys.map{|name| create_by_name(name) }
        .flatten.map{|h| plaintext_for(h)}.join("\n\n\n")
    end

    def test_print_all 
        File.write("#{licenses_dir}/plain.txt", get_all_plaintext)
    end

    ## Generate test methods
    REMOTE_LICENSES.keys.each do |name|
      define_method(:"test_#{name}") do 
        _, remote = create_by_name(name)
        license_compare_or_export(name, remote)
      end
    end 

    def test_write_placeholder_licenses
      File.write("#{licenses_dir}/placeholder_licenses.txt", 
        REMOTE_LICENSES.keys.map do |name| 
          generate_for(create_by_name(name)[0])
        end.join("\n\n\n")
      )
    end 


    def test_generate_csharp
      strings = REMOTE_LICENSES.keys.map do |name| 
        id, remote = create_by_name(name)

        id = LicenseGenerator.generate_with_info(id, key, passphrase)
        remote = LicenseGenerator.generate_with_info(remote, key, passphrase)

        pascalName = name.to_s.split('_').collect(&:capitalize).join 

        [{name: "#{pascalName}Placeholder", value: id[:encoded], text: id[:text]},
        {name: "#{pascalName}Remote", value: remote[:encoded], text: remote[:text]}]
      end.flatten

      dict_rows = strings.map{|h| "    { \"#{h[:name]}\", #{h[:name]}},"}

      fieldLines = strings.map{ |h| h[:text].lines.map{|l| "/// #{l.strip}"} + ["public const string #{h[:name]} = \"#{h[:value]}\";", ""]}

      lines = ["// Autogenerated below this point - do not edit - use imazen/licensing test/support/licenses/license_strings.cs ",
        "public static IReadOnlyDictionary<string, string> Licenses { get; } = new Dictionary<string,string>", 
        "{"] + dict_rows + ["};",""] + fieldLines

      csharp = "        " + lines.join("\n        ")
      File.write("#{licenses_dir}/license_strings.cs", csharp)
    end 

    def test_generate_rust
      strings = REMOTE_LICENSES.keys.map do |name| 
        id, remote = create_by_name(name)

        id = LicenseGenerator.generate_with_info(id, key, passphrase)
        remote = LicenseGenerator.generate_with_info(remote, key, passphrase)

        capsName = name.to_s.upcase()


        [{name: "#{capsName}_PLACEHOLDER", value: id[:encoded], text: id[:text]},
        {name: "#{capsName}_REMOTE", value: remote[:encoded], text: remote[:text]}]
      end.flatten

      dict_rows = strings.map{|h| "  map.insert(\"#{h[:name]}\", #{h[:name]});"}

      fieldLines = strings.map{ |h| h[:text].lines.map{|l| "/// #{l.strip}"} + ["pub const #{h[:name]}: &'static str= \"#{h[:value]}\";", ""]}

      lines = ["// Autogenerated below this point - do not edit - use imazen/licensing test/support/licenses/license_strings.rs ",
        "fn create_licenses_hash() -> HashMap<&'static str, &'static str>{",
        "  let mut map = HashMap::new();"] + 
         dict_rows  + [
          "  map",
          "}",
          "lazy_static!{",
          "  pub static ref LICENSES: HashMap<&'static str, &'static str> = create_licenses_hash();",
          "}",
          ""
        ] + fieldLines

      File.write("#{licenses_dir}/license_strings.rs", lines.join("\n"))
    end 
  end
end
