require 'chargebee'

module ImazenLicensing
  class Chargebee

    def configure
      ChargeBee.configure({:api_key => ENV["CHARGEBEE_TEST_KEY"], :site => "imazen-test"})
    end

    # def fetch_plan
#       ChargeBee::Subscription.retreive("HtZEwKYQCgKZqsR1C")
#     result = ChargeBee::Subscription.create({
#   :id => "sub_KyVqDh__dev__NTn4VZZ1", 
#   :plan_id => "basic", 
# })
  end
end 
