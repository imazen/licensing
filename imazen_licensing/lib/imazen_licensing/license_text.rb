require "base64"
require "time"
module ImazenLicensing
  class LicenseText
    FIELDS=[:status, 
            :owner,
            :product, 
            :kind,
            :domain,
            :servers,
            :total_cores,
            :sku, 
            :features,
            :is_public,
            :locator,
            :issued, 
            :expires,
             :expiry_version, 
             :restrictions]


    attr_accessor *FIELDS
 
    
    def stringify(v)
      if v.is_a?(Array) then 
        v.join(" ")
      elsif v.is_a?(Time) then
        v.iso8601
      else
        v.to_s
      end
    end 

    
    def body
      FIELDS.map do |key|
        value = self.send(key)
        if value.nil? 
          nil
        else 
          k = key.to_s.split('_').map(&:capitalize).join("")
          "#{k}: #{stringify(value)}"
        end 
      end.compact.join("\n")
    end 

    def summary
      if self.domain.nil?
        ""
      else 
        "#{domain}(#{sku} includes #{stringify(features)})"
      end 
    end 

    def sign(signing_key, key_passphrase)
      g = ::ImazenLicensing::LicenseGenerator.new
      rsa = OpenSSL::PKey::RSA.new(signing_key, key_passphrase)
      self.full = g.produce_full_license(summary, text, self.body)
    end 

    #def decoded
    #  Base64.decode64(self.full.split(":")[-2]).force_encoding("UTF-8")
    #end
  end

end