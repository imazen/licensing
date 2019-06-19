# Imazen Licensing

Gem and endpoint for asymmetric license key pair generation with S3 hosted license files. 


[![Build Status](https://travis-ci.org/imazen/licensing.svg?branch=master)](https://travis-ci.org/imazen/licensing)


## Secrets used by rails app

```
    :user_name      => ENV['SMTP_USER'] || 'store@store.imazen.io',
  :password       => ENV['SMTP_PASSWORD'] || 'redacted',
  :domain         => ENV['SMTP_DOMAIN'] || 'store.imazen.io',
  :address =>     ENV['SMTP_SERVER'] || 'smtp.mailgun.org',
   
- AWS, for uploading license files
- CHARGEBEE_DOMAIN
- chargebee_secret
- secret to validate webook 
- 
 config.license_signing_key_passphrase = ENV['LICENSE_SIGNING_KEY_PASSPHRASE']
 config.license_signing_key = ENV['LICENSE_SIGNING_KEY_BLOB'].gsub(/\\n/,"\n")
TEST_LICENSE_SIGNING_KEY_PASSPHRASE
TEST_LICENSE_SIGNING_KEY_BLOB'] || "").gsub(/\\n/,"\n") 


  if config.license_signing_key.blank? 
    config.license_signing_key = OpenSSL::PKey::RSA.new(2048).export(OpenSSL::Cipher::AES256.new(:CBC), config.license_signing_key_passphrase)
  end 


```
TODO: Write a gem description


## Id (placeholder) licenses have the following fields
* `Id`
* `Secret`
* `Kind: 'id'`
* `IsPublic: false`
* `Owner: name`
* `NetworkGraceMinutes: integer`
* (possibly LicenseServers, Issued)

## Remote licenses have the following fields

* `Id`
* `Owner: name`
* `IsPublic: true`
* `Features: `
* `Issued: `
* (optionally) `Expires: `
* `MustBeFetched: true`
* (optionally) SubscriptionExpirationDate, Domains, 
* (optionally) kind, explanatory fields about subscription type, interval, duration, due date, etc.

## Revoked licenses 

* `Id`
* `IsPublic: true`
* `Owner: name`
* `Valid: false` 

## All license fields and interpretation

* `Id: 'lowercasealphanumeric'`: Unique identifier for the license
* `Secret: 'lowercasealphanumeric'`: Secret key that permits remote license retrieval. 
* `Kind: [id | domain | subscription ]`: `id` means the license is a placeholder for a remote domain. 
* `IsPublic: true`: License fields (excluding Secret) are displayed on a public web-service endpoint
* `Owner: Company or Name`: Name of the licensee (required)
* `Domain: lowercase.com`: Used as the license identifier if the Id field is absent. One of the two is required.
* `Domains: a.com b.com c.com` and `Domain: d.com`: Serves to restrict usage of the license to requests with the given hostname(s). 
* `Features: FeatureA VersionXFeatureB`: Space-delimited feature codes. If these serve to activate all features that are in use, then the license is considered valid. 
* `Valid: false`: The license has been revoked
* `NetworkGraceMinutes: integer`: For a placeholder license that has never been fetched/cached to disk: how many minutes to delay enforcement while attempting to connect to the internet. 
* `Expires: iso8601 date`: When the license becomes invalid
* `Issued: iso8601 date`: When the license becomes valid
* `SubscriptionExpirationDate: iso8601 date`: Product builds after this date are not valid with this license
* `LicenseServers: https://s3-us-west-2.amazonaws.com/licenses.imazen.net/ https://licenses-redirect.imazen.net/ https://licenses.imazen.net/ https://licenses2.imazen.net/
* `MustBeFetched: true`: Don't validate the license unless it comes from a license server (or its cache).




## License forms

### Version-specific offline 1-domain license

```
"#{domain} (#{sku} includes #{features.join(' ')})"

Domain: domain.se
Owner: John Smith
Issued: 2015-10-08T13:43:14Z
Features: R4Elite R4Creative R4Performance

Domain: domain.se
Owner: John Smith
Issued: 2017-04-24T09:16:05Z
Features: R4Performance
Restrictions:  

Domain: domain.se
Owner: John Smith
Issued: 2017-04-17T08:01:44Z
Features: R4Creative R4Performance
Restrictions:  

```

```
"#{domain} (#{sku} includes #{features.join(' ')})"

Domain: domain.se
Owner: John Smith
Issued: 2015-10-08T13:43:14Z
Features: R4Elite R4Creative R4Performance
```

### Id license

```
"License #{id} for #{owner}"


"Kind: #{license[:kind]}
Id: #{license[:id]}
Owner: #{license[:owner]}
Issued: #{license[:issued].iso8601}
Product: #{license[:product]}
Features: #{license[:features].join(' ')}
IsPublic: #{license[:is_public]}"

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'imazen_licensing'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install imazen_licensing

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/[my-github-username]/imazen_licensing/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
