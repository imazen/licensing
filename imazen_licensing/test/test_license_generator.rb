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

    def formatted(license)
      "Kind: #{license[:kind]}
      Sku: #{license[:sku]}
      Domain: #{license[:domain]}
      Features: #{licenses[:features].join(' ')}"
    end

    def key
      @key ||= File.read("#{File.dirname(__FILE__)}/support/test_private_key.pem")
    end

    def passphrase
      'testpass'
    end

    def test_subscription_license
      generated = LicenseGenerator.generate(subscription_license, key, passphrase)
      summary, body, signed = generated.split(':').map(&:strip)
      assert_equal summary, ""
      assert_equal Base64.strict_decode64(body), formatted(subscription_license)
      assert verify_rsa(signed, body, key, passphrase)
    end

    def verify_rsa(signed, body, key, passphrase)
      signature_bytes = Base64.strict_decode64(signed)
      rsa = OpenSSL::PKey::RSA.new(key, passphrase)
      digest = rsa.public_decrypt(signature_bytes)
      body_digest = OpenSSL::Digest::SHA512.new.digest(body)
      digest == body_digest
    end
  end
end