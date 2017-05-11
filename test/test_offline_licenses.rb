require "minitest/autorun"
require "date"
require "imazen_licensing"
require_relative "support/license_test_base"
require "digest"

module ImazenLicensing
  class TestOfflineLicenses <  ImazenLicensing::LicenseTestBase

    def issued
      DateTime.parse('2017-04-21')
    end

    def test_v4_domain_offline
      h = {
        kind: 'v4-domain-offline',
        sku: 'R4Performance',
        domain: 'acme.com',
        owner: 'Acme Corp',
        issued: issued,
        features: ['R4Performance']
      }
      license_compare_or_export(__method__.to_s, h)
    end 

    def test_v4_domain_offline_creative
      h = {
        kind: 'v4-domain-offline',
        sku: 'R4Creative',
        domain: 'acme.com',
        owner: 'Acme Corp',
        issued: issued,
        features: ['R4Creative', 'R4Performance']
      }
      license_compare_or_export(__method__.to_s, h)
    end 
  end
end