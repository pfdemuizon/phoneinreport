class VoiceMailHandler < ActionMailer::Base
  def receive(email)
    logger.info("Processing email...")
    @campaign = Campaign.find_by_email(email.to.first)
    unless @campaign
      logger.warn("Could not find a campaign for #{email.to}.")
      return 
    end
    @report = @campaign.reports.build
    unless @voice_mail = VoiceMail.create(:email => email)
      logger.warn("Error saving voice mail: #{@voice_mail.errors}")
    end
    @report.voice_mail = @voice_mail if @voice_mail
    unless @report.save
      logger.warn("Report errors: #{@report.errors}") 
    end
  end
end
