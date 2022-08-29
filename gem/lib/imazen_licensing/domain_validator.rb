require "public_suffix"
module ImazenLicensing
  class DomainValidator
    def normalize_domain_string(domain)
      domain.strip.downcase.gsub(/\Ahttps?:\/\//i,'').chomp('/').gsub(/\A\.+/,'').gsub(/\.+\Z/,'')
    end 

    def domain_allowed?(domain)
      domain_error(domain).nil?
    end

    def domain_error(domain)
      domain = normalize_domain_string(domain)
      @@additional ||= %w{apphb.com amazonaws.com cloudapp.net azurewebsites.net azureedge.net cloudfront.net cloudapp.azure.com azure.com}
      
      return "The * (wildcard) character is not allowed" if domain =~ /\*/ 

      return "Domain format invalid; domains can only consist of characters [.-0-9a-zA-Z] Expand unicode domain names via Punycode" unless domain =~ /\A[\.\-a-zA-Z0-9]*\Z/ 
      
      
      return "This domain (#{domain}) is not a valid domain; it is listed as a hosting provider. You may only register licenses for domains you control." if @@additional.include?(domain)
      #if true, they are not trying to register a TLD


      return "(#{domain}) is not a valid domain (per publicsuffix.org)"  unless PublicSuffix.valid?(domain, ignore_private: false)
    rescue PublicSuffix::DomainInvalid
        return "(#{domain}) is an invalid domain"
     rescue PublicSuffix::DomainNotAllowed
        return "(#{domain}) is a top-level domain. You may only register licenses for domains you control."
    end
  end
end
    