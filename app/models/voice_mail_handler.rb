class VoiceMailHandler < ActionMailer::Base
  def receive(email)
    logger.info("Processing email...")
    @campaign = Campaign.find_by_email(email.to.first)
    unless @campaign
      logger.error("Could not find a campaign for #{email.to}.")
      return 
    end
    @report = @campaign.reports.build
    unless @voice_mail = VoiceMail.create(:email => email)
      logger.error("Error saving voice mail: #{@voice_mail.errors}")
    end
    @report.voice_mail = @voice_mail if @voice_mail
    logger.error("Before report save...")
    unless @report.save!
      logger.error("Report errors: #{@report.errors}") 
    end
    logger.error("After report save...")
  end
end
