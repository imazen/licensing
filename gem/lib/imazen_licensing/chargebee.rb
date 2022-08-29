require 'chargebee'

module ImazenLicensing
  class Chargebee

    def configure(site: ENV["CHARGEBEE_SITE"], api_key: ENV["CHARGEBEE_API_KEY"])
      ChargeBee.configure({:api_key => api_key, :site => site})
    end
  end
end
