class LicenseHandler
  attr_accessor :message

  def initialize(cb, seed, key, passphrase)
    self.message = cb.message
    @cb = cb
    @seed = seed
    @key = key
    @passphrase = passphrase
    @license_summary = generate_license
    @sha = Digest::SHA256.hexdigest(@license_summary[:id_license][:encoded])
  end

  def self.call(cb, seed, key, passphrase)
    handler = new(cb, seed, key, passphrase)
    handler.maybe_send_license_email
    handler.update_license_id_and_hash
    handler.upload_to_s3
    handler.message.join("\n") + "#{ENV['SOURCE_VERSION']}"
  end

  # @TODO: handle cancellations
  # @TODO: push billing issue data and subscription status
  def generate_license
    id_license_params, id_license = generate_id_license
    license_type_params = params_for_license_type
    _license_params, license = generate_license_with_params(license_type_params)

    {
      id_license: id_license,
      license: license,
      secret: id_license_params[:secret],
      id: id_license_params[:id]
    }
  end

  def update_license_id_and_hash
    subscription_id = cb.subscription['id']
    api_key = ENV["CHARGEBEE_API_KEY"]
    site = ENV["CHARGEBEE_SITE"]
    url = "https://#{site}.chargebee.com/api/v2/subscriptions/#{subscription_id}"
    self.message << "#{self.class}: fetching subscription #{subscription_id} from ChargeBee API."
    response = HTTParty.get(url,{basic_auth: {username: api_key}})
    if response.ok? && response&.fetch("subscription").present?
      current_subscription = response.fetch("subscription").reject { |k,v| k == "trial_end" }
      new_subscription = current_subscription.merge({
        "cf_license_id" => @license_summary[:id],
        "cf_license_hash" => @sha
      }).compact

      if (new_subscription.to_a - current_subscription.to_a).present?
        self.message << "#{self.class}: posting subscription #{subscription_id} back to ChargeBee API."
        HTTParty.post(url,{body: new_subscription, basic_auth: {username: api_key}})
      else
        self.message << "#{self.class}: license unchanged for subscription #{subscription_id}; no post to ChargeBee API"
      end
    end
  end

  def maybe_send_license_email
    if @sha != cb.subscription["cf_license_hash"]
      self.message << "#{self.class}: sending id license email to #{cb.customer_email}"
      LicenseMailer.id_license_email(
        emails: [cb.customer_email],
        id_license_encoded: @license_summary[:id_license][:encoded],
        id_license_text: @license_summary[:id_license][:text],
        remote_license_text: @license_summary[:license][:text]
      ).deliver_now
    else
      self.message << "#{self.class}: subscription 'cf_license_hash' and checked sha are identical, no email sent"
    end
  end

  def upload_to_s3
    s3_uploader = ImazenLicensing::S3::S3LicenseUploader.new(aws_id: aws_id,
                                                             aws_secret: aws_secret)

    self.message << "#{self.class}: uploading license to S3"
    s3_uploader.upload_license(license_id: @license_summary[:id],
                               license_secret: @license_summary[:secret],
                               full_body: @license_summary[:license][:encoded])
  end

  private

  attr_reader :cb

  def aws_id
    ENV["LICENSE_S3_ID"]
  end

  def aws_secret
    ENV["LICENSE_S3_SECRET"]
  end

  def generate_id_license
    id_license_params = {
      kind: 'id',
      id: cb.id, # we generate this (lowercase, numeric)
      owner: cb.owner,
      secret: cb.license_secret(@seed),
      issued: cb.subscription["created_at"],
      network_grace_minutes: 480,
      is_public: false
    }

    id_license = ImazenLicensing::LicenseGenerator.generate_with_info(id_license_params, @key, @passphrase)

    [id_license_params, id_license]
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

  # TODO:
  # Add company or non-profit restrictions based on cb.coupon_strings
  # Always set subscription_expiration_date
  # if perpetual license add-on is present, lift expires date..
  def params_for_license_type
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

  def generate_license_with_params(license_type_params)
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
      restrictions: license_restrictions.join(' ')
    }.merge(license_type_params)

    license = ImazenLicensing::LicenseGenerator.generate_with_info(license_params, @key, @passphrase)

    [license_params, license]
  end
end
