module ImazenLicensing
  class V1LicenseText
    attr_reader :data

    def self.supported_kinds
      ['v4-domain-offline']
    end 
    
    def initialize(data)
      @data = data
      validate
    end

REQUIRED=[:domain, :owner, :issued, :features, :sku]
ALLOWED=[:expires, :kind]

MUST_BE_DATES=[:issued, :expires]
    def validate
      unless (REQUIRED - @data.keys).empty?
        raise "#{self.class.name} requires fields #{REQUIRED}"
      end
      not_allowed = ((@data.keys - REQUIRED) - ALLOWED)
      unless not_allowed.empty?
        raise "#{self.class.name} does not allow fields #{not_allowed}"
      end

      unless @data.select{ |k,v| MUST_BE_DATES.include? (k)}.all?{|k,v| v.respond_to?(:iso8601)}
        raise "#{self.class.name} requires fields #{MUST_BE_DATES} to be valid dates and respond to .iso8601"
      end

      domain_error =  DomainValidator.new.domain_error(data[:domain])
      raise domain_error if domain_error
      
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