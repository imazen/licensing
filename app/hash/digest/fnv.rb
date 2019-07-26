module Digest 
  class FNV
    def self.offset
        2166136261
    end
    
    def self.prime
        16777619
    end

    def self.calculate(input, length=32)
      hash = self.offset
      prime = self.prime
      input.each_byte { |b| hash = (hash * prime) ^ b }
      mask = (2 ** length) -1
      hash & mask
    end
    
    def self.hexdigest(input, length=32)
      self.calculate(input, length).to_s(16)
    end
  end
end
