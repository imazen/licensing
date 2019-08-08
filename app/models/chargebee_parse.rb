class ChargebeeParse
  TIMESTAMP_FIELDS = [
    'started_at', 'activated_at', 'next_billing_at',
    'created_at', 'updated_at', 'current_term_start',
    'current_term_end', 'cancelled_at', 'trial_start', 'trial_end'
  ]
  attr_accessor :subscription, :customer, :plan, :event_type

  def initialize(params)
    self.subscription = params.dig("content", "subscription") || {}
    parse_subscription_timestamps
    self.customer = params.dig("content", "subscription") || {}
    self.event_type = params["event_type"]
  end

  def maybe_update_subscription_and_customer
    # compare Time.zone.now to subscription updated_at. if >3 seconds, fetch everything new
    if (subscription_updated_at < Time.zone.now - 3.seconds)
      self.subscription = ChargeBee::Subscription.retrieve(self.subscription["id"]).subscription.as_json
      parse_subscription_timestamps
      self.customer = ChargeBee::Customer.retrieve(self.subscription["customer_id"]).customer.as_json
    end
  end

  def licensed_domains
    domains = self.subscription["cf_licensed_domains"] || ""
    domains.split(" ")
  end

  def id
    @id ||= Digest::FNV.calculate([created_from_ip,subscription["id"]].join(''), 30).to_s.rjust(8,"0")
  end

  def license_secret(seed)
    Digest::SHA256.hexdigest([self.id, seed].join(''))
  end

  def created_from_ip
    IPAddr.new(subscription["created_from_ip"].split(",").first).to_i if subscription["created_from_ip"]
  end

  def plan_id
    subscription["plan_id"]
  end

  def subscription_quantity
    subscription["plan_quantity"]
  end

  def coupon_strings
    (subscription["coupons"] || []).map{|v| [v["coupon_id"], v["coupon_code"]]}.flatten.compact.uniq
  end

  def plan
    @plan ||= ChargeBee::Plan.retrieve(plan_id).plan
  end


  def plan_cores
    plan.meta_data.fetch(:cores)
  end

  def restrictions
    plan.meta_data[:restrictions]
  end

  def kind
    plan.meta_data.fetch(:kind)
  end

  def features
    plan.meta_data.fetch(:features)
  end

  def network_grace_minutes
    plan.meta_data.fetch(:network_grace_minutes)
  end

  def listed_domains_min
    plan.meta_data.fetch(:listed_domains_min)
  end

  def listed_domains_max
    plan.meta_data.fetch(:listed_domains_max)
  end



  def product
    plan.invoice_name
  end

  def is_public
    plan.meta_data.fetch(:is_public)
  end


  def subscription_metadata
    subscription["meta_data"]
  end

  def subscription_grace_minutes
    plan.meta_data.fetch(:subscription_grace_minutes,20160)
  end

  # for License Text

  def issued
    subscription["started_at"]
  end

  def term_end_guess
    return subscription["cancelled_at"] if subscription["cancelled_at"]
    return subscription["current_term_end"] if subscription["current_term_end"]
    return subscription["trial_end"] if subscription["trial_end"]
  end

  def customer_email
    customer["email"]
  end

  def subscription_expiration_date
    subscription["current_term_end"]
  end

  def owner
    customer["company"] || [
      customer["first_name"],
      customer["last_name"]
    ].join(" ")
  end

  def subscription_updated_at
    subscription["updated_at"]
  end

  def site_license?
    plan_id == "imageflow-site-license"
  end

  private

  def parse_subscription_timestamps
    TIMESTAMP_FIELDS.each do |field|
      subscription[field] = parse_date(subscription[field])
    end
  end

  def parse_date(object)
    (object.present? || nil) && Time.zone.at(Integer(object)).to_datetime
  end
end
