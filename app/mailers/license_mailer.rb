class LicenseMailer < ApplicationMailer
  def id_license_email(mailer_name:, emails:, id_license_encoded:, id_license_text:, remote_license_text:)
    @id_license_body = id_license_encoded
    @id_license_text = id_license_text
    @remote_license_text = remote_license_text

    subject_lines = {
        "imageresizer" => "ImageResizer",
        "imageflow" => "Imageflow",
        "both" => "Imageflow & ImageResizer"
    }
    subject = "#{subject_lines[mailer_name]} License Delivery"

    mail(to: emails, bcc: OUR_EMAILS, subject: subject, template_name: "#{mailer_name.downcase}_id_license_email")
  end

  def we_fucked_up(e,params)
    mail(to: OUR_EMAILS,
         subject: "An exception occurred in the licensing webhook",
         body: [
           e.message,
           e.backtrace.join("\n"),
           params.inspect
         ].join("\n")
        )
  end

  def domains_under_min(email, domains_max)
    @domains_max = domains_max
    mail(to: email, bcc: OUR_EMAILS, subject: 'Licensing Issue', template_name: 'domains_under_min')
  end

  # @TODO not yet implemented
  # def domains_over_max(email, domains_max)
  #   @domains_max = domains_max
  #   mail(to: email, bcc: OUR_EMAILS, subject: 'Licensing Issue', template_name: 'domains_over_max')
  # end
end
