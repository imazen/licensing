module ImazenLicensing
  class ValidatingHash
    attr_reader :data

    def initialize(data)
      @data = sanitize(data)
      validate
    end

    def validate
      raise "You must override the validate method and call the appropriate fields"
    end

    def sanitize(hash)
      hash.select { |k,v| !v.nil? && !v.to_s.empty? }
    end

    def prohibit_fields(field_names)
      if (field_names - @data.keys).empty?
        raise "#{self.class.name} prohibits fields #{field_names}"
      end
    end

    def require_fields(field_names)
      unless (field_names - @data.keys).empty?
        raise "#{self.class.name} requires fields #{field_names}"
      end
    end

    def require_values(key, values)
      unless values.include?(@data[key]) || values.include?(@data[key].to_s)
        raise "#{self.class.name} requires field #{key} to exist and have one of these values: '#{values.inspect}' (found #{@data[key]})"
      end
    end

    def require_maximum_date(field_names, maximum)
      unless @data.select{ |k,v| field_names.include?(k)}.all?{|k,v| v <= maximum }
        raise "#{self.class.name} requires fields #{field_names} to be no greater than #{maximum}"
      end
    end

    def require_dates_be_valid(field_names)
      unless @data.select{ |k,v| field_names.include?(k)}.all?{|k,v| v.respond_to?(:iso8601)}
        raise "#{self.class.name} requires fields #{field_names} to be valid dates and respond to .iso8601"
      end
    end

    def require_lowercase_alphanumeric(key, min_length = 1)
      unless @data[key] && @data[key].length >= min_length
        raise "#{self.class.name} requires field #{key} to have #{min_length} or more lowercase alphanumeric characters (found #{@data[key].length})"
        unless /\A[0-9a-z]+\z/ =~ @data[key]
          raise "#{self.class.name} requires field #{key} to only contain lowercase alphanumeric characters (found #{@data[key]})"
        end
      end
    end 

    def require_min_length(field_name, min_length = 1)
      unless @data[field_name] && @data[field_name].strip.length >= min_length
        raise "The #{field} field is required, and must contain at least #{min_length} characters (found #{@data[key].strip.length})"
      end 
    end 

    def prohibit_duplicate_fields(&block)
      # Check for overlapping fields
      dupe_keys = @data.keys.map{|k| [block.call(k), k] }
                              .group_by{|a| a[0]}.select{|k,v| v.count > 1 }.map{|k,v| v.map{|a| a[1]}}
      if dupe_keys.count > 0
        raise "The following duplicate fields were found: #{dupe_keys.inspect}"  
      end 
    end 

    def prohibit_chars_in(values, bad_chars, subject)
      chars = bad_chars.chars
      if values.map{|v| v.to_s}.any?{ |v| chars.any?{|c| v.include?(c)}}
        raise "#{subject} may not contain any of #{chars.to_s}" 
      end 
    end 

    def prohibit_characters(bad_chars = "\r\n\\<>")
      prohibit_chars_in((@data.values + @data.keys), bad_chars, "Field names and values")
    end

    def prohibit_characters_in_fields(bad_chars = ":")
      prohibit_chars_in(@data.keys, bad_chars, "Field names")
    end
  end
end
