require 'base64'

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
      klass = [V2IdLicenseText, V2RemoteLicenseText, V1LicenseText]
              .select{|c| c.supported_kinds.include?(options[:kind])}.first

      if klass
        klass
      else
          raise "Kind not recognized: #{options[:kind]}"
      end
    end
  end
end