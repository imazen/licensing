require 'base64'

module ImazenLicensing
  class LicenseGeneration

    
    def sign_text(text, rsa)
      digest_bytes = digest(text)
      encrypted_bytes = rsa.private_encrypt(digest_bytes, OpenSSL::PKey::RSA::PKCS1_PADDING) # "\0".b + digest_bytes + "\0".b
      Base64.strict_encode64(encrypted_bytes)
    end

    def produce_full_license(comment, text, rsa)
      b64 = Base64.strict_encode64(text)
      sig = sign_text(text,rsa)
      "#{comment}:#{b64}:#{sig}" 
    end


    def digest(text)
      OpenSSL::Digest::SHA512.new.digest(text)
    end

    def print_debug_info(text,rsa)
      STDERR << "\nOriginal modulus: " + rsa.params["n"].to_s
      STDERR << "\nOriginal Exponent: " + rsa.params["e"].to_s
      STDERR << "\nOriginal sha512: " + digest(text).unpack("H*").join + "\n"
    end

    def get_exponent(rsa)
      get_param(rsa,"e")
    end 
    def get_modulus(rsa)
      get_param(rsa,"n")
    end

    def get_param(rsa, name)
      Base64.strict_encode64(rsa.params[name].to_s)
    end

    private :get_param, :digest, :sign_text

  end
end
