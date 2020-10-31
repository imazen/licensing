module ImazenLicensing
  class V1LicenseText
    attr_reader :data

    def self.supported_kinds
      ['v4-domain-offline']
    end 
    
    def initialize(data)
      @data = sanitize(data)
      validate
    end

REQUIRED=[:domain, :owner, :issued, :features, :sku]
ALLOWED=[:expires, :kind, :restrictions]

    def validate
      unless (REQUIRED - @data.keys).empty?
        raise "#{self.class.name} requires fields #{REQUIRED}"
      end
      not_allowed = ((@data.keys - REQUIRED) - ALLOWED)
      unless not_allowed.empty?
        raise "#{self.class.name} does not allow fields #{not_allowed}"
      end

      require_dates_be_valid( [:issued] )
      require_dates_be_valid( [:expires] )
      require_dates_be_valid( [:imageflow_expires] )

      domain_error =  DomainValidator.new.domain_error(data[:domain])
      raise domain_error if domain_error
      
    end 

    def require_dates_be_valid(field_names)
      pairs = @data.select{ |k,v| field_names.include? (k)}
      unless pairs.all?{|k,v| v.respond_to?(:iso8601)}
        raise "#{self.class.name} requires fields #{field_names} to be valid dates and respond to .iso8601, found #{pairs.inspect}"
      end
    end 

    def sanitize(hash)
      hash.select { |k,v| !v.nil? && !v.to_s.empty? }
    end

    def summary
      "#{data[:domain]}(#{data[:sku] || 'SKU missing'} includes #{stringify(data[:features])})"
    end

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
      data.map do |k,v|
        key_str = k.is_a?(Symbol) ? k.to_s.split('_').map(&:capitalize).join("") : k
        "#{key_str}: #{stringify(v)}"
      end.compact.join("\n")
    end 
  end
end 