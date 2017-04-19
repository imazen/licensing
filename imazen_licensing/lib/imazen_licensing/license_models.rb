require "time"

module ImazenLicensing
  class LicenseModels

    def self.issued
      Time.parse("2017-03-29T03:13:58Z")
    end 
    def self.perpetual_perf_domain_v4
      l = LicenseText.new 
      l.sku = "R4Performance"
      #l.product = "Imageflow Domain license"
      l.owner = "Acme Corp"
      #l.kind = "domain"
      #l.status = "OK"
      l.domain = "acme.com"
      #l.is_public = true
      #l.locator = 1,
      l.issued = issued
      #l.expires = Time.now.utc + (24*60*60*30)
      l.features = ["R4Performance"]
      l.restrictions = []
      l
    end 
    def self.perpetual_creative_domain_v4
      l = LicenseText.new 
      l.sku = "R4Creative"
      #l.product = "Imageflow Domain license"
      l.owner = "Acme Corp"
      #l.kind = "domain"
      #l.status = "OK"
      l.domain = "acme.com"
      #l.is_public = true
      #l.locator = 1,
      l.issued = issued
      #l.expires = Time.now.utc + (24*60*60*30)
      l.features = ["R4Creative", "R4Performance"]
      l.restrictions = []
      l
    end 
    def self.perpetual_elite_v4
      l = LicenseText.new 
      l.sku = "R4Elite"
      #l.product = "Imageflow Domain license"
      l.owner = "Acme Corp"
      #l.kind = "domain"
      #l.status = "OK"
      #l.domain = "acme.com"
      l.is_public = true
      #l.locator = 1,
      l.issued = issued
      #l.expires = Time.now.utc + (24*60*60*30)
      l.features = ["R4Elite", "R4Creative", "R4Performance"]
      l.restrictions = []
      l
    end 
    def site_license_1yr_v4
      l = LicenseText.new 
      l.sku = "R4Performance"
      #l.product = "Imageflow Domain license"
      l.owner = "Acme Corp"
      #l.kind = "domain"
      #l.status = "OK"
      l.domain = "acme.com"
      #l.is_public = true
      #l.locator = 1,
      l.issued = Time.now.utc - (24*60*60)
      #l.expires = Time.now.utc + (24*60*60*30)
      l.features = ["R4Performance"]
      l.restrictions = []
      l
    end 



  end
end 