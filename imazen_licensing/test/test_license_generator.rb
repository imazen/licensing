require "minitest/autorun"
require "openssl"
require "imazen_licensing"

module ImazenLicensing
  class TestLicenseGenerator <  Minitest::Test

    def issued
      @issued ||= DateTime.now
    end

    def subscription_license
      {
        kind: 'subscription',
        sku: 'subscription_test',
        issued: issued,
        features: ['R4Elite']
      }
    end

    def domain_license
      {
        kind: 'domain',
        sku: 'R4Performance',
        domain: 'acme.com',
        issued: issued,
        features: ['R4Performance']
      }
    end

    def version_license
      {
        kind: 'version',
        sku: 'R4Elite',
        issued: issued,
        features: ['R4Elite', 'R4Creative', 'R4Performance']
      }
    end

    def key
      @key ||= File.read("#{File.dirname(__FILE__)}/support/test_private_key.pem")
    end

    def passphrase
      'testpass'
    end

    def test_subscription_license
      LicenseGenerator.generate(subscription_license, key, passphrase)
    end
  end
end