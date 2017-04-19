#ruby test_licenses.rb

require "minitest/autorun"
require "openssl"
require "imazen_licensing"

module ImazenLicensing

  class TestLicenses <  Minitest::Test
    ORG_SIZE_RESTRICTIONS = ["< 25", "< 100", "< 500", "< 2000"].map{|v| "For orgs with #{v} employees."}
    USAGE_RESTRICTIONS = ["NON-PROFIT USE ONLY", 
                          "EDUCATIONAL USE ONLY", 
                          "PERSONAL USE ONLY", 
                          "NON-COMMERCIAL USE ONLY",
                          "STAGING/TESTING USE ONLY",
                          "SMALL BUSINESS USE ONLY (< 100k yearly revenue)",
                          "No SAAS resale", "No OEM distribution"]
    FEATURES = ["imageflow_tool", "imageflow_server std", "imageflow_server datacenter", "libimageflow", "IR_Creative", "IR_Performance", "IR_Elite"]                 

    def domain_license
      l = LicenseText.new 
      l.sku = "IF_Domain"
      l.product = "Imageflow Domain license"
      l.owner = "Acme Corp"
      l.kind = "domain"
      l.status = "OK"
      l.domain = "acme.com"
      l.is_public = true
      l.locator = 1,
      l.issued = Time.now.utc - (24*60*60)
      l.expires = Time.now.utc + (24*60*60*30)
      l.features = FEATURES
      l.restrictions = USAGE_RESTRICTIONS
      l
    end 

    def mono_works
      begin 
        `bash -c 'command -v mono'`
      rescue
      end
      $?.success?
    end 

    def roundtrip(verifier, summary, text )
      g = ImazenLicensing::LicenseGeneration.new
      rsa = OpenSSL::PKey::RSA.new 2048
      license = g.produce_full_license(summary, text, rsa)
      worked = verifier.verify(license, g.get_modulus(rsa), g.get_exponent(rsa),true,false)

      g.print_debug_info(text, rsa) unless worked

      assert_equal true, worked
    end 
    def test_roundtrip
      assert mono_works
      #skip("Mono not installed, skipping licenses roundtrip test") unless $?.success?
      cs =  ImazenLicensing::LicenseVerifierCs.new
      10.times do 
        roundtrip(cs, domain_license.summary, domain_license.body)
      end 
    end 
  end 
end 



