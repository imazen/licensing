require 'base64'

module ImazenLicensing
  class LicenseGenerator

    def self.generate(options = {}, key, passphrase)
      new.generate(options, key, passphrase)
    end

    def self.generate_with_info(options = {}, key, passphrase)
      new.generate_with_info(options, key, passphrase)
    end

    def generate(options, key, passphrase)
      generate_with_info(options, key, passphrase)[:encoded]
    end

    def generate_with_info(options, key, passphrase)
      sanitized = licenser(options).new(options)
      text = sanitized.body
      summary_text = sanitized.summary
      encoded_body = encode(text)
      { 
        encoded: "#{summary_text} :#{encoded_body}:#{sign(text, key, passphrase)}",
        summary: summary_text,
        text: text,
      } 
    end

    private
    def encode(string)
      Base64.strict_encode64(string)
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
