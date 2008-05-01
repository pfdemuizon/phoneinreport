class VoiceMailHandler < ActionMailer::Base
  def receive(email)
    logger.info("Processing email...")
    @campaign = Campaign.find_by_email(email.to)
    unless @campaign
      logger.warn("Could not find a campaign for #{email.to}.")
      return
    end
    @report = @campaign.reports.build 
    if email.subject =~ /MaxEmail voice message from (\d+)/
      @report.phone = $1
    else
      logger.warn("Email subject does not contain a phone number.")
    end
    @report.created_at = email.date.to_time
    if email.has_attachments? 
      email.attachments.each do |attachment|
        logger.info("Processing attachment...")
        next unless attachment.content_type == "audio/wav"
        @voice_mail = VoiceMail.new
        @voice_mail.uploaded_data = attachment
        if email.body =~ /The reference number for this message is (\d+-\w+)./
          @voice_mail.max_email_ref_num = $1
        else
          logger.warn("Email subject does not contain a phone number.")
        end
        if @voice_mail.valid?
          logger.info("Saving attachment...")
          @voice_mail.save
        else
          logger.warn("Invalid voice mail")
        end
        break
      end
    end
    @report.voice_mail = @voice_mail if @voice_mail
    unless @report.save
      logger.warn("Report errors: #{@report.errors}")
    end
  end
end
