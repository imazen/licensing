class ChargebeeController < ApplicationController
  rescue_from StandardError, with: :log_error
  before_action :ensure_valid_key, :check_subscription

  def index
    cb = ChargebeeParse.new(params)
    cb.maybe_update_subscription_and_customer

    raise "Domain count incorrect" unless domains_count_ok?(cb)
    license = generate_license(cb)

    sha = Digest::SHA256.hexdigest(license[:id_license][:encoded])

    if sha != cb.subscription["cf_license_hash"]
      LicenseMailer.id_license_email(
        emails: [cb.customer_email],
        id_license_encoded: license[:id_license][:encoded],
        id_license_text: license[:id_license][:text],
        remote_license_text: license[:license][:text]
      ).deliver
    end

    update_license_id_and_hash(cb.subscription["id"],
                               license[:id], sha)


    s3_uploader = ImazenLicensing::S3::S3LicenseUploader.new(aws_id: ENV["LICENSE_S3_ID"],
                                                             aws_secret: ENV["LICENSE_S3_SECRET"])

    s3_uploader.upload_license(license_id: license[:id], license_secret: license[:secret], full_body: license[:license][:encoded])

    head :no_content
  end

  def log_error(e)
    LicenseMailer.we_fucked_up(e,params).deliver_now
    raise e
  end

  private

  def domains_count_ok?(cb)
    return true if cb.site_license?
    domains = cb.licensed_domains
    return false if domains.length < cb.listed_domains_min || domains.length > cb.listed_domains_max
    true
  end

  def generate_license(cb)
    key = Web::Application.config.license_signing_key
    passphrase = Web::Application.config.license_signing_key_passphrase

    license_id = cb.id # fnv digest of clientip and id
    license_secret = Digest::SHA256.hexdigest([cb.id, ENV["LICENSE_SECRET_SEED"]].join(''))


    id_license_params = {
      kind: 'id',
      id: license_id, # we generate this (lowercase, numeric)
      owner: cb.owner,
      secret: license_secret,
      issued: cb.subscription["created_at"],
      network_grace_minutes: 480,
      is_public: false
    }

    id_license = ImazenLicensing::LicenseGenerator.generate_with_info(id_license_params, key, passphrase)


    restrictions = [cb.restrictions] + { "MICROENTERPRISE_ONLY" => "Only valid for organizations with less than 5 employees.",
                                         "SMALLBIZ_ONLY" => "Only valid for organizations with less than 30 employees.",
                                         "SMB_ONLY" => "Only valid for organizations with less than 500 employees.",
                                         "NONPROFIT_ONLY" => "Only valid for non-profit organizations."
    }.map do |k,v|
      cb.coupon_strings.any?{|s| s.include? (k) } ? v : nil
    end

    restrictions = restrictions.compact.uniq


    # TODO:
    # Add company or non-profit restrictions based on cb.coupon_strings
    # Always set subscription_expiration_date
    # if perpetual license add-on is present, lift expires date..


    extra_fields = case cb.kind
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

    # @TODO: handle cancellations
    # @TODO: push billing issue data and subscription status

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
      restrictions: restrictions.join(' ')
    }.merge(extra_fields)

    license = ImazenLicensing::LicenseGenerator.generate_with_info(license_params, key, passphrase)


    {
      id_license: id_license,
      license: license,
      secret: license_secret,
      id: license_id
    }
  end


  def update_license_id_and_hash(subscription_id, license_id, license_hash)
    api_key = ENV["CHARGEBEE_API_KEY"]
    site = ENV["CHARGEBEE_SITE"]
    url = "https://#{site}.chargebee.com/api/v2/subscriptions/#{subscription_id}"
    response = HTTParty.get(url,{basic_auth: {username: api_key}})
    if response.ok? && response.respond_to?(:[]) && response["subscription"].present?
      current_subscription = response["subscription"].reject { |k,v| k == "trial_end" }
      new_subscription = current_subscription.merge({
        "cf_license_id" => license_id,
        "cf_license_hash" => license_hash
      }).compact

      if (new_subscription.to_a - current_subscription.to_a).present?
        HTTParty.post(url,{body: new_subscription, basic_auth: {username: api_key}})
        return true
      end
    end
    false
  end

  def ensure_valid_key
    unless params[:key] == ENV["CHARGEBEE_WEBHOOK_TOKEN"]
      head :forbidden
    end
  end

  def check_subscription
    # Ignore events that lack a subscription
    if params.fetch("content", {}).fetch("subscription", nil).nil?
      head :no_content
    end
  end
end