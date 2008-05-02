require File.dirname(__FILE__) + '/../spec_helper'

# Need to test VoiceMailHanlder#receive, but that invokes
# ActionMailer::Base.receve which expects a raw_email object
# that is difficult to mock. therefore, simply overwrite
# this method for this test so we can call our method
class ActionMailer::Base
  def receive(mail)
    new.receive(mail)
  end
end

describe VoiceMailHandler do
  before do
  end
  describe "when receiving voice mails" do
    def act!
      VoiceMailHandler.receive(@email) 
    end
    it "should up correct campaign" do
      Campaign.should_receive(:find_by_email).with('voicemail@radicaldesigns.org').and_return(@mock_campaign)
      act!
    end
    it "should pull phone number from subject" do
      #@report.should_receive(:phone).with('4152790322')
      #@incoming_voice_mail_handler.receive(@email)
    end
    it "should receive date from email header" do
      #@report.should_receive(:date).with(
      #@incoming_voice_mail_handler.receive(@email)
    end
    it "should save voice mail" do
      #@report.should_receive(:voice_mail).with('4152790322')
      #@incoming_voice_mail_handler.receive(@email)
    end
  end
end
