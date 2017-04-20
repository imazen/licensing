module ImazenLicensing
  class V2LicenseText
    attr_reader :data

    REQUIRED = [
      :id, 
      :is_public,
      :kind,
      :owner,
      :issued,
      :features,
      :product
    ]

    REQUIRE_FOR_ID = [
      :kind,
      :id,
      :secret,
      :is_public
    ]
    MUST_BE_DATES=[:issued, :expires, :no_releases_after]

    def initialize(data)
      @data = data
      validate
    end

    def validate
      if data[:kind] == 'id' then
          unless (REQUIRE_FOR_ID - @data.keys).empty?
          raise "#{self.class.name} requires fields #{REQUIRED}"
        end
      else
        unless (REQUIRED - @data.keys).empty?
          raise "#{self.class.name} requires fields #{REQUIRED}"
        end
        unless @data.select{ |k,v| MUST_BE_DATES.include? (k)}.all?{|k,v| v.respond_to?(:iso8601)}
          raise "#{self.class.name} requires fields #{MUST_BE_DATES} to be valid dates and respond to .iso8601"
        end
      end
    end

    def body
      data.map do |k,v|
        key_str = k.is_a?(Symbol) ? k.to_s.split('_').map(&:capitalize).join("") : k
        "#{key_str}: #{stringify(v)}"
      end.compact.join("\n")
    end

    def summary
      data[:product]
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
  end
end