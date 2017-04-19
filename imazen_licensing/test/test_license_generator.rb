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
        owner: 'Acme',
        issued: issued,
        features: ['R4Performance']
      }
    end

    def version_license
      {
        kind: 'version',
        sku: 'R4Elite',
        owner: 'Acme',
        issued: issued,
        features: ['R4Elite', 'R4Creative', 'R4Performance']
      }
    end

    def formatted(license)
      "Kind: #{license[:kind]}
Sku: #{license[:sku]}
Domain: #{license[:domain]}
Owner: #{license[:owner]}
Issued: #{license[:issued].iso8601}
Features: #{license[:features].join(' ')}"
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
      assert_equal formatted(subscription_license), Base64.strict_decode64(body)
      assert verify_rsa(signed, body, key, passphrase)
    end

    def test_domain_license
      generated = LicenseGenerator.generate(domain_license, key, passphrase)
      summary, body, signature = generated.split(':').map(&:strip)
      decoded_body = Base64.strict_decode64(body).force_encoding('UTF-8')

      assert_equal summary, "acme.com(R4Performance includes R4Performance)"
      assert_equal formatted(domain_license), decoded_body
      assert verify_rsa(signature, decoded_body, key, passphrase)
    end

    def verify_rsa(signature, decoded_body, key, passphrase)
      signature_bytes = Base64.strict_decode64(signature)
      rsa = OpenSSL::PKey::RSA.new(key, passphrase)

      digest = rsa.public_decrypt(signature_bytes, OpenSSL::PKey::RSA::PKCS1_PADDING)
      body_digest = OpenSSL::Digest::SHA512.new.digest(decoded_body)
      assert_equal digest, body_digest
    end

    def test_rsa
      rsa = OpenSSL::PKey::RSA.new(key, passphrase)
      data = "hello"
      encrypted = rsa.private_encrypt(data, OpenSSL::PKey::RSA::PKCS1_PADDING) # "\0".b + digest_bytes + "\0".b
      decrypted = rsa.public_decrypt(encrypted, OpenSSL::PKey::RSA::PKCS1_PADDING)
      assert_equal data, decrypted
    end

  end
end