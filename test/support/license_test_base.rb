require "minitest/autorun"
require "openssl"
require "date"
require "base64"
require "imazen_licensing"

module ImazenLicensing
  class LicenseTestBase <  Minitest::Test

    def key
      @key ||= File.read("#{File.dirname(__FILE__)}/test_private_key.pem")
    end

    def passphrase
      'testpass'
    end

    def licenses_dir
      "#{File.dirname(__FILE__)}/licenses"
    end 

    def license_path(name, hash)
      "#{licenses_dir}/#{hash[:id] || hash[:domain]}/#{name}.txt"
    end 

    def license_export(name, hash)
      dirname = File.dirname(license_path(name, hash))
      unless File.directory?(dirname)
        Dir.mkdir(dirname)
      end

      license = generate_for(hash)
      File.write(license_path(name, hash), license)
      _, plain, _ = license_parse(license)
      File.write(license_path("#{name}_plain" , hash), plain)
    end

    def license_compare_or_export(name, hash)
      if File.exist?(license_path(name, hash))
        license_compare(name, hash)
      else
        license_export(name,hash)
      end 
    end 

    def license_parse(license)
      summary, body, signed = license.split(':').map(&:strip)
      decoded_body = Base64.strict_decode64(body).force_encoding('UTF-8')
      [summary, decoded_body, signed]
    end 

    def generate_for(hash)
      LicenseGenerator.generate(hash, key, passphrase)
    end
    def plaintext_for(hash)
      summary, decoded_body, _ = license_parse(generate_for(hash))
      "#{summary}:...\n\n#{decoded_body}"
    end

    def license_compare(name, hash)
      summary, decoded_body, signed = license_parse(generate_for(hash))
      assert verify_rsa(signed, decoded_body, key, passphrase)

      expected = File.read(license_path(name, hash))
      expected_summary, expected_decoded_body, expected_signed = license_parse(expected)

      assert_equal expected_summary, summary
      assert_equal expected_decoded_body, decoded_body
      assert_equal expected_signed, signed
    end

    def license_should_fail(name, hash)
      assert_raises StandardError do
        summary, decoded_body, signed = license_parse(generate_for(hash))
        verify_rsa(signed, decoded_body, key, passphrase)
      end
    end

    def verify_rsa(signature, decoded_body, key, passphrase)
      signature_bytes = Base64.strict_decode64(signature)
      rsa = OpenSSL::PKey::RSA.new(key, passphrase)

      digest = rsa.public_decrypt(signature_bytes, OpenSSL::PKey::RSA::PKCS1_PADDING)
      body_digest = OpenSSL::Digest::SHA512.new.digest(decoded_body)
      assert_equal digest, body_digest
    end

  end
end
