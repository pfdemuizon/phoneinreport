class IncomingVoiceMailHandler < ActionMailer::Base
  def receive(email)
=begin
    logger = RAILS_DEFAULT_LOGGER
    logger.info(">>>>>>>>>>>")
    logger.info("date: #{email.date}")
    logger.info("from: #{email.from}")
    logger.info("to: #{email.to}")
    logger.info("subject: #{email.subject}")
    logger.info("body: #{email.body}")
    email.attachments.each do |a|
      logger.info("attachments content-type: #{a.content_type}")
    end
    logger.info("<<<<<<<<<<<")
=end
    @campaign = Campaign.find_by_email(email.to)
    unless @campaign
      logger.warn("Could not find a campaign with this email address: #{email.to}")
      return
    end
    @report = @campaign.reports.build 
    if email.subject =~ /MaxEmail voice message from (\d*)/
      @report.phone = $1
    else
      logger.warn("No phone number include in email.")
    end
    @report.created_at = email.date.to_time
    if email.has_attachments? 
      email.attachments.each do |attachment|
        next unless a.content_type == "audio/wav"
        @voice_mail = @report.voice_mail.build
        @voice_mail.filename = attachment.original_filename
        @voice_mail.uploaded_data = attachment.read
        @voice_mail.save
        break
      end
    else
      logger.warn("Email did not contain voice mail attachment.")
    end
    @report.save
  end
end
