require 'open3'

module ImazenLicensing
  class LicenseVerifierCs
    def initialize
      @path = nil
    end 
    def ensure_compiled
      if @path.nil?
        @path = File.expand_path(File.join(File.dirname(__FILE__),"license_verifier"))

        output = `mcs #{@path}.cs #{@path}_interfaces.cs -g -out:#{@path}.exe  -r:System.Numerics.dll`

        abort "Failed to compile #{@path}: #{output}" unless $?.success?
      end
    end 

    def verify(data, modulus, exponent, debug, verbose)

      ensure_compiled

      cmd = "mono --debug #{@path}.exe #{modulus} #{exponent}" + (debug ? " -d" : "")
      output, ps = Open3.capture2e(cmd, :stdin_data=>data)

      valid = ps.success? 
      
      errd = output.include?("Exception") || (!valid && debug)

      if errd
        abort "FAILED !!! #{cmd}\n #{output} \n\n\nGiven:\n\n#{data}" 
      elsif verbose
        STDERR << "#{cmd}\n #{output} \n\n\nGiven:\n\n#{data}\n"
      end 

      valid 
    end

  end
end
