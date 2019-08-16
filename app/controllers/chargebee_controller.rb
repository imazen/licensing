class ChargebeeController < ApplicationController
  rescue_from StandardError, with: :log_error
  before_action :ensure_valid_key, :check_subscription

  def index
    cb = ChargebeeParse.new(params)
    cb.maybe_update_subscription_and_customer
    seed = ENV["LICENSE_SECRET_SEED"]
    key, passphrase = license_signing_key, license_signing_passphrase

    send_domain_emails(cb) and return unless domains_count_ok?(cb)
    LicenseHandler.call(cb, seed, key, passphrase)

    render plain: "Testing we can see this"
  end

  def log_error(e)
    LicenseMailer.we_fucked_up(e,params).deliver_now
    raise e
  end

  private

  def domains_count_ok?(cb)
    return true unless cb.domains_required?
    false if cb.domains_under_min? || cb.domains_over_max?
  end

  def send_domain_emails(cb)
    if cb.domains_under_min?
      LicenseMailer.domains_under_min(cb.customer_email, cb.listed_domains_max).deliver_now
      message = cb.message << "Domains under minimum, sent email to #{cb.customer_email}"
      render plain: message.join("\n")
    elsif cb.domains_over_max?
      raise "Someone tried to register with too many domains"
      # @TODO: not yet implemented
      # LicenseMailer.domains_over_max(cb.customer_email, cb.listed_domains_max).deliver_now
    end
  end

  def ensure_valid_key
    head :forbidden if params[:key] != ENV["CHARGEBEE_WEBHOOK_TOKEN"]
  end

  def check_subscription
    # Ignore events that lack a subscription
    render plain: "No subscription given; webhook event: #{webhook_event}" if params.dig("content", "subscription").blank?
  end

  def license_signing_key
    Web::Application.config.license_signing_key
  end

  def license_signing_passphrase
    Web::Application.config.license_signing_key_passphrase
  end

  def webhook_event
    params["event_type"] || "not given"
  end
end
