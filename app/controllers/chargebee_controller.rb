class ChargebeeController < ApplicationController
  rescue_from StandardError, with: :log_error
  before_action :ensure_valid_key, :check_subscription

  def index
    cb = ChargebeeParse.new(params)
    cb.maybe_update_subscription_and_customer
    subscription_id = cb.subscription["id"]
    seed = ENV["LICENSE_SECRET_SEED"]
    key, passphrase = license_signing_key, license_signing_passphrase

    raise "Domain count incorrect" unless domains_count_ok?(cb)
    license = ChargebeeLicenseGenerator.generate_license(cb, seed, key, passphrase)
    sha = Digest::SHA256.hexdigest(license[:id_license][:encoded])

    maybe_send_license_email(cb, sha, license)
    update_license_id_and_hash(subscription_id, license[:id], sha)

    upload_to_s3(license, ENV["LICENSE_S3_ID"], ENV["LICENSE_S3_SECRET"])

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
    head :forbidden if params[:key] != ENV["CHARGEBEE_WEBHOOK_TOKEN"]
  end

  def check_subscription
    # Ignore events that lack a subscription
    head :no_content if params.dig("content", "subscription").empty?
  end

  def license_signing_key
    Web::Application.config.license_signing_key
  end

  def license_signing_passphrase
    Web::Application.config.license_signing_key_passphrase
  end

  def maybe_send_license_email(cb, sha, license)
    if sha != cb.subscription["cf_license_hash"]
      LicenseMailer.id_license_email(
        emails: [cb.customer_email],
        id_license_encoded: license[:id_license][:encoded],
        id_license_text: license[:id_license][:text],
        remote_license_text: license[:license][:text]
      ).deliver
    end
  end

  def upload_to_s3(license, aws_id, aws_secret)
    s3_uploader = ImazenLicensing::S3::S3LicenseUploader.new(aws_id: ENV["LICENSE_S3_ID"],
                                                             aws_secret: ENV["LICENSE_S3_SECRET"])

    s3_uploader.upload_license(license_id: license[:id], license_secret: license[:secret], full_body: license[:license][:encoded])
  end
end
