class ChargebeeLicenseGenerator
  def initialize(cb, seed, key, passphrase)
    @cb = cb
    @seed = seed
    @key = key
    @passphrase = passphrase
  end

  def self.generate_license(cb, seed, key, passphrase)
    new(cb, seed, key, passphrase).generate_license
  end

  def generate_license
    id_license_params, generated_id_license = generate_id_license(@cb, @seed, @key, @passphrase)

    license_type_params = params_for_license_type(@cb)

    # @TODO: handle cancellations
    # @TODO: push billing issue data and subscription status

    _license_params, license = generate_license_with_params(@cb, license_type_params, @key, @passphrase)

    {
      id_license: generated_id_license,
      license: license,
      secret: id_license_params[:secret],
      id: id_license_params[:id]
    }
  end

  private

  def generate_id_license(cb, license_secret_seed, key, passphrase)
    id_license_params = {
      kind: 'id',
      id: cb.id, # we generate this (lowercase, numeric)
      owner: cb.owner,
      secret: cb.license_secret(license_secret_seed),
      issued: cb.subscription["created_at"],
      network_grace_minutes: 480,
      is_public: false
    }

    generated_id_license = ImazenLicensing::LicenseGenerator.generate_with_info(id_license_params, key, passphrase)

    [id_license_params, generated_id_license]
  end

  def license_restrictions(cb)
    [cb.restrictions] + { "MICROENTERPRISE_ONLY" => "Only valid for organizations with less than 5 employees.",
                          "SMALLBIZ_ONLY" => "Only valid for organizations with less than 30 employees.",
                          "SMB_ONLY" => "Only valid for organizations with less than 500 employees.",
                          "NONPROFIT_ONLY" => "Only valid for non-profit organizations."
    }.map do |k,v|
      cb.coupon_strings.any?{|s| s.include? (k) } ? v : nil
    end.compact.uniq
  end

  def params_for_license_type(cb)
    # TODO:
    # Add company or non-profit restrictions based on cb.coupon_strings
    # Always set subscription_expiration_date
    # if perpetual license add-on is present, lift expires date..

    case cb.kind
    when "per-core"
      {
        max_servers: cb.subscription_quantity,
        total_cores: cb.plan_cores * cb.subscription_quantity,
      }
    when "per-core-domain"
      {
        max_servers: cb.subscription_quantity,
        total_cores: cb.plan_cores * cb.subscription_quantity,
        domains: cb.licensed_domains
      }
    when "site-wide"
      {

      }
    when "oem"
      {
        only_for_use_within: cb.subscription["cf_for_use_within_product_oem_redistribution"],
        # @TODO: set subscription_expiration_date immediately to prevent newer binaries from being used with a oem revoked license
      }
    else
      {}
    end
  end

  def generate_license_with_params(cb, license_type_params, key, passphrase)
    license_params = {
      id: cb.id, # we generate this (lowercase, numeric)
      owner: cb.owner,
      kind: cb.kind, # from plan
      issued: cb.issued,
      expires: cb.term_end_guess.advance( minutes: cb.subscription_grace_minutes),
      features: cb.features, # from plan
      product: cb.product, # from plan
      must_be_fetched: true,
      is_public: cb.is_public,
      restrictions: license_restrictions(cb).join(' ')
    }.merge(license_type_params)

    license = ImazenLicensing::LicenseGenerator.generate_with_info(license_params, key, passphrase)

    [license_params, license]
  end
end
