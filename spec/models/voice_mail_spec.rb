require File.dirname(__FILE__) + '/../spec_helper'

describe VoiceMail do
  before do
    @attachment = TMail::Attachment.new
    @attachment.original_filename = File.join(RAILS_ROOT, 'spec', "voice_mail_test.wav")
    @attachment.content_type = "audio/wav"
    @attachment.string = IO.read(@attachment.original_filename)
    @email = TMail::Mail.load(File.join(RAILS_ROOT, 'spec', 'email_test.txt'))
    @email.stub!(:attachments).and_return([@attachment])
    @email.stub!(:has_attachments?).and_return(true)
  end

  describe("when created") do
    def act!
      @voice_mail = VoiceMail.new(:email => @email)
    end

    it "should get created at date from email header" do 
      act!
      @voice_mail.created_at.should == @email.date.to_time
    end
    
    it "should parse the phone number from the subject" do 
      act!
      @voice_mail.phone.should == '5556667777'
    end

    it "should handle non-numeric phone number" do
      @email.subject = 'MaxEmail voice message from an unknown sender'
      act!
      @voice_mail.phone.should == "unknown sender"
    end
    
    it "should parse the max email reference number from the body" do 
      act!
      @voice_mail.max_email_ref_num.should == '8156429451-AK02W4IG'
    end

    it "should convert wav file attachment to mp3" do
      act!
      @voice_mail.save
      @voice_mail.filename.should == "voice_mail_test.mp3"
      File.exists?(@voice_mail.full_filename).should be_true
    end
  end
end
