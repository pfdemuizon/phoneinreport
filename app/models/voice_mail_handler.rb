class VoiceMailHandler < ActionMailer::Base
  dump = Logger.new(File.join(RAILS_ROOT,'log', 'mail_errors.log'))
  def receive(email)
    dump.info("Processing email...")
    @campaign = Campaign.find_by_email(email.to.first)
    unless @campaign
      dump.warn("Could not find a campaign for #{email.to}.")
      return 
    end
    @report = @campaign.reports.build
    unless @voice_mail = VoiceMail.create(:email => email)
      dump.warn("Error saving voice mail: #{@voice_mail.errors}")
    end
    @report.voice_mail = @voice_mail if @voice_mail
    unless @report.save
      dump.warn("Report errors: #{@report.errors}") 
    end
  end
end
