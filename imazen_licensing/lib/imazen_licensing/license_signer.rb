module ImazenLicensing
  class LicenseSigner
    def self.sign(text, key, passphrase)
      new.sign(text, key, passphrase)
    end

    def sign(text, key, passphrase)
      digest_bytes = digest(text)
      encrypted_bytes = rsa(key, passphrase).private_encrypt(digest_bytes, OpenSSL::PKey::RSA::PKCS1_PADDING) # "\0".b + digest_bytes + "\0".b
      Base64.strict_encode64(encrypted_bytes)
    end

    def digest(text)
      OpenSSL::Digest::SHA512.new.digest(text)
    end

    def rsa(key, passphrase)
      OpenSSL::PKey::RSA.new(key, passphrase)
    end
  end
end