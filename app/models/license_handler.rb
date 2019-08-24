class LicenseHandler
  attr_accessor :message

  def initialize(cb, seed, key, passphrase)
    self.message = cb.message
    @cb = cb
    @seed = seed
    @key = key
    @passphrase = passphrase
  end

  def self.call(cb, seed, key, passphrase)
    handler = new(cb, seed, key, passphrase)
    handler.maybe_send_license_email
    handler.maybe_update_subscription
    handler.upload_to_s3
    handler.message.join("\n") + "#{ENV['SOURCE_VERSION']}"
  end

  def maybe_send_license_email
    if license_hash != cb.subscription["cf_license_hash"]
      self.message << "#{self.class}: sending id license email to #{cb.customer_email}"
      LicenseMailer.id_license_email(
        emails: [cb.customer_email],
        id_license_encoded: license_summary[:id_license][:encoded],
        id_license_text: license_summary[:id_license][:text],
        remote_license_text: license_summary[:license][:text]
      ).deliver_now
    else
      self.message << "#{self.class}: subscription 'cf_license_hash' and generated sha are identical, no email sent"
    end
  end

  def maybe_update_subscription
    subscription_id = cb.subscription['id']
    api_key = ENV["CHARGEBEE_API_KEY"]
    site = ENV["CHARGEBEE_SITE"]
    url = "https://#{site}.chargebee.com/api/v2/subscriptions/#{subscription_id}"
    self.message << "#{self.class}: fetching subscription #{subscription_id} from ChargeBee API."
    response = HTTParty.get(url,{basic_auth: {username: api_key}})
    if response.ok? && response&.fetch("subscription").present?
      current_subscription = response.fetch("subscription").reject { |k,v| k == "trial_end" }
      new_subscription = current_subscription.merge({
        "cf_license_id" => license_summary[:id],
        "cf_license_hash" => license_hash
      }).compact

      if (new_subscription.to_a - current_subscription.to_a).present?
        self.message << "#{self.class}: posting subscription #{subscription_id} back to ChargeBee API."
        HTTParty.post(url,{body: new_subscription, basic_auth: {username: api_key}})
      else
        self.message << "#{self.class}: license unchanged for subscription #{subscription_id}; no post to ChargeBee API"
      end
    end
  end

  def upload_to_s3
    s3_uploader = ImazenLicensing::S3::S3LicenseUploader.new(aws_id: aws_id,
                                                             aws_secret: aws_secret)

    self.message << "#{self.class}: uploading license to S3"
    s3_uploader.upload_license(license_id: license_summary[:id],
                               license_secret: license_summary[:secret],
                               full_body: license_summary[:license][:encoded])
  end

  private

  attr_reader :cb

  # @TODO: handle cancellations
  # @TODO: push billing issue data and subscription status
  def license_summary
    secret = cb.license_secret(@seed)

    @license_summary ||= {
      id_license: generate_id_license(cb.id, secret),
      license: generate_license,
      secret: secret,
      id: cb.id # we generate this (lowercase, numeric)
    }
  end

  def aws_id
    ENV["LICENSE_S3_ID"]
  end

  def aws_secret
    ENV["LICENSE_S3_SECRET"]
  end

  def generate_id_license(cb_id, secret)
    id_license_params = {
      kind: 'id',
      id: cb_id,
      owner: cb.owner,
      secret: secret,
      issued: cb.subscription["created_at"],
      network_grace_minutes: 480,
      is_public: false
    }

    ImazenLicensing::LicenseGenerator.generate_with_info(id_license_params, @key, @passphrase)
  end

  def generate_license
    ImazenLicensing::LicenseGenerator.generate_with_info(license_params, @key, @passphrase)
  end

  def license_hash
    @license_hash ||= Digest::SHA256.hexdigest(license_summary[:id_license][:encoded])
  end

  def license_restrictions
    [cb.restrictions] + { "MICROENTERPRISE_ONLY" => "Only valid for organizations with less than 5 employees.",
                          "SMALLBIZ_ONLY" => "Only valid for organizations with less than 30 employees.",
                          "SMB_ONLY" => "Only valid for organizations with less than 500 employees.",
                          "NONPROFIT_ONLY" => "Only valid for non-profit organizations."
    }.map do |k,v|
      cb.coupon_strings.any?{|s| s.include? (k) } ? v : nil
    end.compact.uniq
  end

  def license_params
    {
      id: cb.id, # we generate this (lowercase, numeric)
      owner: cb.owner,
      kind: cb.kind, # from plan
      issued: cb.issued,
      expires: cb.expires_on,
      features: cb.features, # from plan
      product: cb.product, # from plan
      must_be_fetched: true,
      is_public: cb.is_public,
      restrictions: license_restrictions.join(' ')
    }.merge(conditional_license_params)
  end

  def conditional_license_params
    cancelled_license_params.merge(license_type_params)
  end

  def cancelled_license_params
    if cb.subscription['status'] == 'cancelled'
      {
        subscription_expiration_date: cb.subscription['cancelled_at'],
        message: 'Message: Your subscription has expired; please renew to access newer product releases.'
      }
    else
      {}
    end
  end

  # TODO:
  # Add company or non-profit restrictions based on cb.coupon_strings
  # Always set subscription_expiration_date
  def license_type_params
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
end
