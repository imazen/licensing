module ImazenLicensing
  class LicenseGenerator

    def self.generate(options = {}, key, passphrase)
      new.generate(options, key, passphrase)
    end

    def generate(options, key, passsphrase)
      sanitized = sanitize(options)
      text = license_text(sanitized)
      "#{summary(sanitized)}\n#{sign(text, key, passphrase)}"
    end

    private
    def sanitize(options)
      options.select { |k,v| !v.nil? && !v.to_s.empty? }
    end

    def license_text(options)
      licenser(options).body(options)
    end

    def sign(license_text, key, passphrase)
      LicenseSigner.sign(license_text, key, passphrase)
    end

    def summary(options)
      licenser(options).summary(options)
    end

    def licenser(options)
      case options[:kind]
        when 'subscription'
        when 'version'
          V2LicenseText
        when 'domain'
          V1LicenseText
        else
          raise "failsauce"
      end
    end
  end
end