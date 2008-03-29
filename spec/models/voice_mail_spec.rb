require File.dirname(__FILE__) + '/../spec_helper'

describe VoiceMail do
  before(:each) do
    @voice_mail = VoiceMail.new
  end

  it "should save wav attachment as mp3" do
    attachment = TMail::Attachment.new
    attachment.original_filename = "voice_mail_test.wav"
    attachment.content_type = "audio/wav"
    attachment.string = IO.read(File.join(RAILS_ROOT, 'spec', attachment.original_filename))
    @voice_mail.uploaded_data = attachment
    @voice_mail.save
  end
end
