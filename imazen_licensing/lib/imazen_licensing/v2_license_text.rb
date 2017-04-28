module ImazenLicensing
  class V2LicenseText < ValidatingHash

    def validate
      prohibit_characters("\r\n\\<>")
      prohibit_characters_in_fields(":")
      prohibit_duplicate_fields {|k| stringify_key(k).downcase }
      require_dates_be_valid [:issued, :expires, :subscription_expiration_date]
      require_lowercase_alphanumeric(:id, 8)
      require_min_length(:owner, 2)
      
      raise "Summary cannot contain colons (found #{summary})" if summary.include?(':')
      raise "License body exceeds 30,000 character limit" if body.length > 30000
    end

    def summary
      "License #{data[:id]} for #{data[:owner]}"
    end

    def body
      data.map do |k,v|
        "#{stringify_key(k)}: #{stringify_value(v)}"
      end.compact.join("\n")
    end

    def stringify_key(k)
      k.is_a?(Symbol) ? k.to_s.split('_').map(&:capitalize).join("") : k
    end 

    def stringify_value(v)
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