require File.dirname(__FILE__) + '/../spec_helper'

describe VoiceMailHandler do
  before(:each) do
    @email = stub('email', :null_object => true,
        :date => Time.now.to_s, 
        :from => 'maxemail-bounce@maxemail.com',
        :to => 'voicemail@radicaldesigns.org', 
        :subject => 'MaxEmail voice message from 4152790322',
        :body =>  "You received a voice message from 4152790322 on Thu, 27 Mar 2008 14:16:37 -0700\nThe message is attached to this email.\n\nThe caller ID for this voice message is 4152790322.\n\nThe reference number for this message is 8156429113-AK02RBW2.\n\nA WAV audio player program is required to open and listen to this message. \nPlease visit the MaxEmail software information center at\nhttp://www.maxemail.com/static/services_sw.html\nfor information about where to download software.\n\nPlease visit the Help section at http://www.maxemail.com/static/faq.html\nif you have any questions regarding this message or your MaxEmail service.\n\nThank you for using MaxEmail!\n",
        :attachments => [stub('attachment', :original_filename => 'ak02rbw2.wav', :content_type => 'audio/wav', :read => 'datadatadata')]
    )
    @mock_voice_mail = mock_model(VoiceMail, :null_object => true, :save => true)
    @mock_voice_mail_has_one_association = mock('voice_mail_has_on_association', :build => @mock_voice_mail)
    @mock_report = mock_model(Report, :voice_mail => @mock_voice_mail)
    @mock_reports = mock('reports', :build => @mock_report)
    @mock_campaign = mock_model(Campaign, :reports => @mock_reports, :email => @email.to) 
  end
  describe "when receiving voice mails" do
    it "should pull up correct campaign" do
require 'ruby-debug'
debugger
      Campaign.should_receive(:find_by_email).with('voicemail@radicaldesigns.org').and_return(@mock_campaign)
      VoiceMailHandler.receive(@email)
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
