class IncomingVoiceMailHandler < ActionMailer::Base
  def receive(email)
    @campaign = Campaign.find_by_email(email.to)
    unless @campaign
      logger.warn("Could not find a campaign with this email address: #{email.to}")
      return
    end
    @report = @campaign.reports.build 
    if email.subject =~ /MaxEmail voice message from (\d*)/
      @report.phone = $1
    else
      logger.warn("Phone number not included in email.")
    end
    @report.created_at = email.date.to_time
    if email.has_attachments? 
      email.attachments.each do |attachment|
        next unless attachment.content_type == "audio/wav"
        @voice_mail = VoiceMail.new
        @voice_mail.uploaded_data = attachment
        @voice_mail.save
        break
      end
    end
    if @voice_mail
      logger.warn("Email did not contain voice mail attachment.") 
    else
      @report.voice_mail = @voice_mail
    end
    @report.save
  end
end
