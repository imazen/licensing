require 'dotenv/load'
require 'sinatra'
require 'pry'

post '/chargebee' do
    binding.pry
    unless params['key'] == ENV['CHARGEBEE_WEBHOOK_TOKEN']
        return 403 
    end

    # Ignore events that lack a subscription
    if params.fetch("content",{}).fetch("subscription", nil).nil?
        head :no_content
        return
    end


    cb = ChargebeeParse.new(params)


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


    s3_uploader = ImazenLicensing::S3::S3LicenseUploader.new(aws_id: Rails.application.secrets.license_s3_id,
    aws_secret: Rails.application.secrets.license_s3_secret)

    s3_uploader.upload_license(license_id: license[:id], license_secret: license[:secret], full_body: license[:license][:encoded])


    head :no_content
end

# error do
#    e = env['sinatra.error']
#    p e.message

#    LicenseMailer.we_fucked_up(e,params).deliver
#    raise e
# end
