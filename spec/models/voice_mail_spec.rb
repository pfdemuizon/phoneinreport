require File.dirname(__FILE__) + '/../spec_helper'

describe VoiceMail do
  before do
    @attachment = TMail::Attachment.new
    @attachment.original_filename = File.join(RAILS_ROOT, 'spec', "voice_mail_test.wav")
    @attachment.content_type = "audio/wav"
    @attachment.string = IO.read(@attachment.original_filename)
    @email = mock('email', :null_object => true,
      :from => 'maxemail-bounce@maxemail.com',
      :to => 'voicemail@radicaldesigns.org', 
      :date => "Thu, 27 Mar 2008 14:16:37 -0700",
      :subject => 'MaxEmail voice message from 5556667777',
      :body =>  "You received a voice message from 5556667777 on Thu, 27 Mar 2008 14:16:37 -0700\nThe message is attached to this email.\n\nThe caller ID for this voice message is 4152790322.\n\nThe reference number for this message is 8156429113-AK02RBW2.\n\nA WAV audio player program is required to open and listen to this message. \nPlease visit the MaxEmail software information center at\nhttp://www.maxemail.com/static/services_sw.html\nfor information about where to download software.\n\nPlease visit the Help section at http://www.maxemail.com/static/faq.html\nif you have any questions regarding this message or your MaxEmail service.\n\nThank you for using MaxEmail!\n",
      :attachments => [@attachment])
  end

  describe("when created") do
    before do
      @voice_mail = VoiceMail.new(@email)
    end

    it "should get created at date from email header" do 
      @voice_mail.created_at.should == 'Thu, 27 Mar 2008 14:16:37 -0700'.to_time
    end
    
    it "should parse the phone number from the subject" do 
      @voice_mail.phone.should == '5556667777'
    end
    
    it "should parse the max email reference number from the body" do 
      @voice_mail.max_email_ref_num.should == '8156429113-AK02RBW2'
    end

    it "should convert wav file attachment to mp3" do
      @voice_mail.save
      @voice_mail.filename.should == "voice_mail_test.mp3"
      File.exists?(@voice_mail.full_filename).should be_true
    end
  end
end
