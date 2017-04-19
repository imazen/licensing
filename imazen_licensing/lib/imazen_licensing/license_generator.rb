module ImazenLicensing
  class LicenseGenerator

    def self.generate(options = {}, key, passphrase)
      new.generate(options, key, passphrase)
    end

    def generate(options, key, passphrase)
      sanitized = sanitize(options)
      text = license_text(sanitized)
      encoded_body = encode(text)
      "#{summary(sanitized)}:#{encoded_body}:#{sign(text, key, passphrase)}"
    end

    private
    def sanitize(options)
      options.select { |k,v| !v.nil? && !v.to_s.empty? }
    end

    def license_text(options)
      licenser(options).new(options).body
    end

    def encode(string)
      Base64.strict_encode64(string)
    end

    def summary(options)
      licenser(options).new(options).summary
    end

    def sign(license_text, key, passphrase)
      LicenseSigner.sign(license_text, key, passphrase)
    end

    def licenser(options)
      case options[:kind]
        when 'subscription', 'version'
          V2LicenseText
        when 'domain'
          V1LicenseText
        else
          raise "failsauce"
      end
    end
  end
end