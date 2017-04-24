#ruby test_licenses.rb

require "minitest/autorun"
require "openssl"
require "date"
require "base64"
require "imazen_licensing"
require "#{File.dirname(__FILE__)}/support/license_verifier_cs"

module ImazenLicensing

  class TestLicenses <  Minitest::Test

    def issued
      @issued ||= DateTime.now
    end

    def domain_license
      {
        kind: 'domain',
        sku: 'R4Performance',
        domain: 'acme.com',
        owner: 'Acme',
        issued: issued,
        features: ['R4Performance']
      }
    end

    def key
      @key ||= File.read("#{File.dirname(__FILE__)}/support/test_private_key.pem")
    end

    def passphrase
      'testpass'
    end

    def mono_works
      begin 
        `bash -c 'command -v mono'`
      rescue
      end
      $?.success?
    end 

    def roundtrip(verifier)
      license = LicenseGenerator.generate(domain_license, key, passphrase)

      modulus, exponent = get_crypto_data(key, passphrase)

      worked = verifier.verify(license, modulus, exponent, true, false)

      assert_equal true, worked
    end

    def get_crypto_data(key, passphrase)
      rsa = LicenseSigner.new.rsa(key, passphrase)
      [
        Base64.strict_encode64(rsa.params['n'].to_s),
        Base64.strict_encode64(rsa.params['e'].to_s)
      ]
    end

    def test_roundtrip
      assert mono_works
      #skip("Mono not installed, skipping licenses roundtrip test") unless $?.success?
      cs = ImazenLicensing::LicenseVerifierCs.new
      10.times do
        roundtrip(cs)
      end 
    end 
  end 
end 



