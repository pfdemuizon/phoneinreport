require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Report do
  before do
    @voice_mail = mock_model(VoiceMail, :null_object => true, :phone => '4152795555')
    @report = Report.new(:city => "San Francisco", :state => "CA")
    @report.voice_mail = @voice_mail
    @geo = mock('geo', :lat => "77.777", :lng => "-111.111", :success => true)
    GeoKit::Geocoders::MultiGeocoder.stub!(:geocode).and_return(@geo)
  end

  it "should insert voice mail phone number into local calling guide url" do
    url = @report.send(:local_calling_guide_url, @voice_mail.phone)
    url.should == "http://www.localcallingguide.com/xmlprefix.php?npa=415&nxx=279"
  end

  describe "when created" do
    def act!
      @report.save
    end

    describe do
      before do
        url = "http://www.localcallingguide.com/xmlprefix.php?npa=415&nxx=279"
        @report.stub!(:local_calling_guide_url).and_return(url)
        @xml_data = {"inputdata"=>[{"nxx"=>["279"], "npa"=>["415"]}], "prefixdata"=>[{"effdate"=>[{}], "switch"=>["CNCRCADOCM5"], "region"=>["CA"], "x"=>[{}], "discdate"=>[{}], "nxx"=>["279"], "ocn"=>["6010"], "rc-h"=>["8719"], "ilec-name"=>["PACIFIC BELL"], "lata"=>["722"], "rc"=>["San Francisco: Central DA"], "ilec-ocn"=>["9740"], "rc-v"=>["8492"], "company-name"=>["BLUE LICENSES HOLDING, LLC"], "npa"=>["415"]}]}
      end
      it "should use local calling guide to set the phone city and state" do
        XmlSimple.should_receive(:xml_in).and_return(@xml_data)
        act!
        @report.phone_city.should == "San Francisco: Central DA"
        @report.phone_state.should == "CA"
      end
    end

    it "should geocode the report" do
      act!
      @report.latitude.should == 77.777 && @report.longitude.should == -111.111
    end
  end
end
