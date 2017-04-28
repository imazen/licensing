module ImazenLicensing
  class V2RemoteLicenseText < V2LicenseText

    def self.supported_kinds
      ['v4-domain', 'v4-elite', 'per-core', 'site-wide', 'oem', 'remote']
    end

    def validate
      super # validates Owner and Id field

      prohibit_fields [:network_grace_minutes, :secret]
      require_fields [:issued, :features]
      require_values :is_public, ['true', 'false']

      if data[:valid].to_s != 'false'

        require_values :must_be_fetched, ['true']
        require_values :kind, self.class.supported_kinds


        domain_validator = DomainValidator.new
        domain_errors = (([data[:domain]] || []) + (data[:domains] || [])).compact.map{|d| domain_validator.domain_error(d)}.compact
        
        raise "Domains failed validation: \n" + domain_errors.join("\n") if domain_errors.length > 0

        if !data[:subscription_expiration_date] &&
           !(data[:features] - ['R4Elite', 'R4Creative', 'R4Performance']).empty? &&
           data[:expires].nil?
           raise "The Expires field is required unless a subscription_expiration_date is specified or only ImageResizer v4 is supported"
        end 
      end
    end 

    def summary
      super + (data[:product] ? " (#{data[:product]})" : "")
    end
  end
end