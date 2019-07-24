require "minitest/autorun"
require "imazen_licensing"
require_relative "support/license_test_base"
require "digest"

module ImazenLicensing
  class TestsForStoreUse <  ImazenLicensing::LicenseTestBase
    
    def key
      @key ||= File.read("#{File.dirname(__FILE__)}/support/test_private_key.pem")
    end

    def passphrase
      'testpass'
    end


    def test_normalize_domain
      v = ImazenLicensing::DomainValidator.new

      assert_equal "domain.com", v.normalize_domain_string("https://domain.com/")
      assert_equal "domain.com", v.normalize_domain_string("http://domain.com/")
      assert_equal "domain.com", v.normalize_domain_string(".domain.com.")
      assert_equal "mydomain.domain.domain.com", v.normalize_domain_string("   mydomain.domain.domain.com ")

    end 

    def test_validate_domain
      v = ImazenLicensing::DomainValidator.new

      [".com", ".net", ".co.uk", "blogspot.com"].each do |domain|
        assert_includes v.domain_error(domain), "is not a valid domain (per publicsuffix.org)"
      end 

      ["apphb.com", "cloudapp.net", "azurewebsites.net"].each do |domain|
        assert_includes v.domain_error(domain), "is not a valid domain"
      end 

      ["domain.com:1215"].each do |domain|
        assert_includes v.domain_error(domain), "format invalid"
      end 
    end 

    def test_v4_domain_offline_creative_for_store
      h = {
        kind: 'v4-domain-offline',
        sku: 'R4Creative',
        domain: 'acme.com',
        owner: 'Acme Corp',
        issued: DateTime.parse('2017-04-21'),
        features: ['R4Creative', 'R4Performance']
      }
      license_compare_or_export(__method__.to_s, h)
    end 

  end
end 