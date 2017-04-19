module ImazenLicensing
  class V1LicenseText
    attr_reader :data
    
    def initialize(data)
      @data = data
      validate
    end

REQUIRED=[:domain, :owner, :issued, :features, :sku]
MUST_BE_DATES=[:issued, :expires, :no_releases_after]
    def validate
      unless (@data.keys - REQUIRED).empty?
        raise "#{self.class.name} requires fields #{REQUIRED}"
      end
      unless @data.select{ |k,v| MUST_BE_DATES.include? (k)}.all?{|k,v| v.responds_to?(:iso8601)}
        raise "#{self.class.name} requires fields #{MUST_BE_DATES} to be valid dates and respond to .iso8601"
      end
    end 

    def summary
      "#{data.domain}(#{data.sku || 'SKU missing'} includes #{stringify(data.features)})"
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
        key_str = k.is_a(Symbol) ? key.to_s.split('_').map(&:capitalize).join("") : k
        "#{key_str}: #{stringify(value)}"
      end.compact.join("\n")
    end 
  end
end 