require "minitest/autorun"
require "imazen_licensing"

module ImazenLicensing
  class ChargbeeTesting < Minitest::Test
    def test_create_license_from_plan
      
      Chargebee.new.configure site: "imazen-test"

      plan_id =  ChargeBee::Subscription.retrieve("HtZEwKYQCgKZqsR1C").subscription.plan_id
      plan_meta = ChargeBee::Plan.retrieve(plan_id).plan
      #puts plan_meta

      # Owner from subscription

      #for id
      #NetworkGraceMinutes

      #for remote
      #kind
      #Features
      #Product
      #
    end

# Id: 2766684890
# Owner: Acme Corp
# Features: R_Elite R_Creative R_Performance
# Product: Enterprise-wide license
# Kind: site-wide
# Issued: 2017-04-21T00:00:00+00:00
# Expires: 2017-06-05T00:00:00+00:00
# IsPublic: true
# MustBeFetched: true
# ManageYourSubscription: https://account.imazen.io
# Restrictions: No resale of usage. Only for organizations with less than 500 employees.

# { 
#    "requiredFields" : ["subscription.cf_for_use_within_product_oem_redistribution"],
#    "fields" : {
#        "SKU": "R_OEM_Monthly",
#        "Restrictions": "Only licensed for use within {{subscription.cf_for_use_within_product_oem_redistribution}}",
#        "Features" : "R_OEM R_Elite, R_Creative, R_Performance",
#        "Network grace period" : "2880"
#    }
# } 

    def test_complete_subscription_id_secret
    end 

    def test_generate_license_for_subscription
    end

    def update_for_subscription
    end

  end
end