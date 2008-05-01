class VoiceMailHandler < ActionMailer::Base
  def receive(email)
    logger.info("Processing email...")
    @campaign = Campaign.find_by_email(email.to)
    unless @campaign
      logger.warn("Could not find a campaign for #{email.to}.")
      return 
    end

    # build report 
    @report = @campaign.reports.build(email)

    # create voice mail
    unless @voice_mail = VoiceMail.create(email)
      logger.warn("Error saving voice mail: #{@voice_mail.errors}")
    end

    # connect voice mail to report
    @report.voice_mail = @voice_mail if @voice_mail
    unless @report.save
      logger.warn("Report errors: #{@report.errors}") 
    end
  end
end
