class LicenseMailer < ApplicationMailer
  OUR_EMAILS = [
    'nathanael.jones@gmail.com',
    'michael.joseph.cohen+imazen+licensing@gmail.com',
    'imazensales@gmail.com',
    'f5d5r0v0l2y2r4j6@imazen.slack.com'
  ]


  def id_license_email(emails:, id_license_encoded:, id_license_text:, remote_license_text:)

    @id_license_body = id_license_encoded
    @id_license_text = id_license_text
    @remote_license_text = remote_license_text

    product = remote_license_text.include?("IMAGEFLOW") ? "Imageflow" : "ImageResizer"

    mail(to: emails, bcc: OUR_EMAILS, subject: "#{product} License Delivery", template_name: "#{product.downcase}_id_license_email")
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
end
