require File.dirname(__FILE__) + '/../spec_helper'

describe VoiceMailHandler do
  before do
    @raw_email = File.open(File.join(RAILS_ROOT, 'spec', 'email_test.txt')).read
  end
  describe "when receiving voice mails" do
    def act!
      VoiceMailHandler.receive(@raw_email) 
    end
    it "should find campaign according to sender email" do
      Campaign.should_receive(:find_by_email).with('voicemail@radicaldesigns.org').and_return(@mock_campaign)
      act!
    end
  end
end
