require 'chargebee'

module ImazenLicensing
  class Chargebee

    def configure (site: , api_key: ENV["CHARGEBEE_API_KEY"])
      ChargeBee.configure({:api_key => api_key, :site => site})
    end

    # def fetch_plan
#       ChargeBee::Subscription.retreive("HtZEwKYQCgKZqsR1C")
#     result = ChargeBee::Subscription.create({
#   :id => "sub_KyVqDh__dev__NTn4VZZ1", 
#   :plan_id => "basic", 
# })
  end
end 
