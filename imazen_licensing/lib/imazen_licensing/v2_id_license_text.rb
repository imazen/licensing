module ImazenLicensing
  class V2IdLicenseText < V2LicenseText
    
    def self.supported_kinds
      ['id']
    end 

    def validate
      super # validates Owner and Id field

      require_values :kind, ['id']
      require_values :is_public, ['false']

      require_lowercase_alphanumeric(:id, 8)
      require_lowercase_alphanumeric(:secret, 32)
      require_fields [:issued, :network_grace_minutes]

      require_values :must_be_fetched, [nil, 'false']

      unless @data[:must_be_fetched].nil? || @data[:must_be_fetched] == "false"
        raise "If present, field must_be_fetched must equal 'false' on an 'id' license"
      end

      unless @data[:network_grace_minutes].to_i > 2
        raise "The :network_grace_minutes value must exceed 2 minutes"
      end 

      # LicenseServers (optional)
    end 
  end
end