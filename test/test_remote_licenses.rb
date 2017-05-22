require "minitest/autorun"
require "date"
require "imazen_licensing"
require_relative "support/license_test_base"
require "digest"

module ImazenLicensing
  class TestLicenseForms <  ImazenLicensing::LicenseTestBase

    def self.issued
      DateTime.parse('2017-04-21')
    end
    def issued
      DateTime.parse('2017-04-21')
    end

    def sha256_hex(v)
      Digest::SHA256.hexdigest v.to_s
    end
    def sha32_dec(v)
      Digest::SHA256.digest(v.to_s)[0..4].unpack("L")[0].to_s
    end

    REMOTE_LICENSES = {
      v4_elite_remote: {
        id: nil,
        owner: 'Acme Corp',
        features: ['R4Elite', 'R4Creative', 'R4Performance'],
        kind: 'v4-elite',
        issued: issued,
        is_public: true,
        must_be_fetched: true,
      },
      v4_domain_remote_subscription: {
        id: nil,
        owner: 'Acme Corp',
        domains: ['box.com', 'stamps.com'],
        features: ['R4Performance'],
        kind: 'v4-domain',
        issued: issued,
        expires: issued +  45, # add 45 days
        is_public: true,
        must_be_fetched: true,
      },
      hard_revocation: {
        id: nil,
        owner: 'Acme Corp',
        features: ['R_Elite', 'R_Creative', 'R_Performance'],
        product: "Enterprise-wide license",
        kind: 'site-wide',
        issued: issued,
        is_public: true,
        valid: false,
        message: 'Please contact support; the license was shared with an unauthorized party and has been revoked.'
      },
      soft_revocation: {
        id: nil,
        owner: 'Acme Corp',
        features: ['R_Elite', 'R_Creative', 'R_Performance'],
        product: "OEM redistribtuion license",
        kind: 'oem',
        issued: issued,
        expires: issued +  45, # add 45 days
        is_public: true,
        must_be_fetched: true,
        subscription_expiration_date: issued,
        message: 'This license has been compromised; please contact Vendor Gamma for an updated license',
        restrictions: "Only for use within Vendor Gamma Prduct"
      },
      perpetual: {
        id: nil,
        owner: 'Acme Corp',
        features: ['R_Elite', 'R_Creative', 'R_Performance'],
        product: "site-wide",
        kind: 'site-wide',
        issued: issued,
        is_public: true,
        must_be_fetched: true,
        subscription_expiration_date: issued,
        message: 'Your subscription has expired; please renew to access newer product releases.'
      },
      cancelled: {
        id: nil,
        owner: 'Acme Corp',
        features: ['R_Elite', 'R_Creative', 'R_Performance'],
        product: "site-wide",
        kind: 'site-wide',
        issued: issued,
        is_public: true,
        must_be_fetched: true,
        valid: false,
        message: 'Your subscription has lapsed; please renew to continue using product.'
      },
      site_wide: {
        id: nil,
        owner: 'Acme Corp',
        features: ['R_Elite', 'R_Creative', 'R_Performance'],
        product: "Enterprise-wide license",
        kind: 'site-wide',
        issued: issued,
        expires: issued +  45, # add 45 days
        is_public: true,
        must_be_fetched: true,
        manage_your_subscription: 'https://account.imazen.io',
        restrictions: "No resale of usage. Only for organizations with less than 500 employees."
      },
      oem: {
        id: nil,
        owner: 'Acme Corp',
        features: ['R_Elite', 'R_Creative', 'R_Performance'],
        product: "OEM redistribtuion license",
        kind: 'oem',
        issued: issued,
        expires: issued +  50, # add 50 days
        is_public: true,
        must_be_fetched: true,
        manage_your_subscription: 'https://account.imazen.io',
        restrictions: "Only for use within Vendor Gamma Prduct"
      },
      cores: {
        id: nil,
        owner: 'Acme Corp',
        features: ['R_Elite', 'R_Creative', 'R_Performance'],
        product: "Per-core license",
        kind: 'per-core',
        issued: issued,
        expires: issued +  50, # add 50 days
        is_public: true,
        must_be_fetched: true,
        max_servers: 4,
        total_cores: 16,
        manage_your_subscription: 'https://account.imazen.io',
      },
      per_core_2_domains: {
        id: nil,
        owner: 'Acme Corp',
        domains: ['acme.com', 'acmestaging.com'],
        features: ['R_Performance'],
        product: "Per Server | 2 Domains | Performance",
        kind: 'per-core-domain',
        issued: issued,
        expires: issued +  50, # add 50 days
        is_public: true,
        must_be_fetched: true,
        max_servers: 4,
        total_cores: 16,
        manage_your_subscription: 'https://account.imazen.io',
      },
      xml: {
        id: nil,
        owner: 'Acme Corp <>',
        domains: ['acme.com', 'acmestaging.com'],
        features: ['R_Performance'],
        product: "Per Server | 2 Domains | Performance",
        kind: 'per-core-domain',
        issued: issued,
        expires: issued +  50, # add 50 days
        is_public: true,
        must_be_fetched: true,
        max_servers: 4,
        total_cores: 16,
        manage_your_subscription: 'https://account.imazen.io',
      }
    }

    def id_license_for(name, remote)
      {
        kind: 'id',
        id: remote[:id],
        secret: "test#{sha256_hex(name)}",
        owner: remote[:owner],
        issued: issued,
        network_grace_minutes: 60 * 8,
        is_public: false,
      }
    end

    def create_by_name(name)
      remote = REMOTE_LICENSES[name]
      remote[:id] = sha32_dec(name)
      id_license = id_license_for(name, remote)
      [id_license, remote]
    end

    def get_all_licenses
      REMOTE_LICENSES.keys.map do |name|
        id, remote = create_by_name(name)
        {id_license: generate_for(id),
          id: id[:id],
          secret: id[:secret],
          remote_license: generate_for(remote),
          id_hash: id,
          id_plaintext: plaintext_for(id),
          remote_hash: remote,
          remote_plaintext: plaintext_for(remote)
        }
      end
    end

    def get_all_plaintext
      REMOTE_LICENSES.keys.map{|name| create_by_name(name) }
        .flatten.map{|h| plaintext_for(h)}.join("\n\n\n")
    end

    def test_print_all
        File.write("#{licenses_dir}/plain.txt", get_all_plaintext)
    end

    ## Generate test methods
    REMOTE_LICENSES.keys.each do |name|
      define_method(:"test_#{name}") do
        _, remote = create_by_name(name)
        license_compare_or_export(name, remote)
      end
    end

    def test_too_far_future_expires
      name = 'moo'
      remote = {
        id: nil,
        owner: 'Acme Corp <>',
        domains: ['acme.com', 'acmestaging.com'],
        features: ['R_Performance'],
        product: "Per Server | 2 Domains | Performance",
        kind: 'per-core-domain',
        issued: issued,
        expires: DateTime.now +  100*365+1, # add 100 years and then some to be over max expiration
        is_public: true,
        must_be_fetched: true,
        max_servers: 4,
        total_cores: 16,
        manage_your_subscription: 'https://account.imazen.io'
      }
      remote[:id] = sha32_dec(name)
      license_should_fail(name, remote)
    end

    def test_write_placeholder_licenses
      File.write("#{licenses_dir}/placeholder_licenses.txt",
        REMOTE_LICENSES.keys.map do |name|
          generate_for(create_by_name(name)[0])
        end.join("\n\n\n")
      )
    end
  end
end
