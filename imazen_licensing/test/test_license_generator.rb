require "minitest/autorun"
require "openssl"
require "date"
require "base64"
require "imazen_licensing"

module ImazenLicensing
  class TestLicenseGenerator <  Minitest::Test

    def issued
      @issued ||= DateTime.now
    end

    def subscription_license
      {
        kind: 'subscription',
        id: '115153162',
        owner: 'Acme',
        issued: issued,
        product: 'imageresizer',
        features: ['R4Elite'],
        is_public: true,
      }
    end

    def id_license
      {
        kind: 'id',
        id: '115153162',
        secret: '1qggq12t2qwgwg4c2d2dqwfweqfw',
        is_public: false,
        max_uncached_grace_minutes: 8 * 60,
        owner: 'Acme Corp'
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

    def formatted_v1(license)
      "Kind: #{license[:kind]}
Sku: #{license[:sku]}
Domain: #{license[:domain]}
Owner: #{license[:owner]}
Issued: #{license[:issued].iso8601}
Features: #{license[:features].join(' ')}"
    end

    def formatted_v2(license)
      "Kind: #{license[:kind]}
Id: #{license[:id]}
Owner: #{license[:owner]}
Issued: #{license[:issued].iso8601}
Product: #{license[:product]}
Features: #{license[:features].join(' ')}
IsPublic: #{license[:is_public]}"
    end

    def formatted_v2_id(license)
      "Kind: id
Id: #{license[:id]}
Secret: #{license[:secret]}
IsPublic: false
MaxUncachedGraceMinutes: #{license[:max_uncached_grace_minutes]}
Owner: #{license[:owner]}"
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
      decoded_body = Base64.strict_decode64(body).force_encoding('UTF-8')

      assert_equal "imageresizer", summary
      assert_equal formatted_v2(subscription_license), Base64.strict_decode64(body)
      assert verify_rsa(signed, decoded_body, key, passphrase)
    end


    def test_id_license
      generated = LicenseGenerator.generate(id_license, key, passphrase)
      summary, body, signed = generated.split(':').map(&:strip)
      decoded_body = Base64.strict_decode64(body).force_encoding('UTF-8')

      assert_equal "License 115153162 for Acme Corp", summary
      assert_equal formatted_v2_id(id_license), Base64.strict_decode64(body)
      assert verify_rsa(signed, decoded_body, key, passphrase)
    end

    def test_domain_license
      generated = LicenseGenerator.generate(domain_license, key, passphrase)
      summary, body, signature = generated.split(':').map(&:strip)
      decoded_body = Base64.strict_decode64(body).force_encoding('UTF-8')

      assert_equal "acme.com(R4Performance includes R4Performance)", summary
      assert_equal formatted_v1(domain_license), decoded_body
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