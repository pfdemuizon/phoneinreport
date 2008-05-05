require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Report do
  before do
    @report = Report.new(:city => "San Francisco", :state => "CA", :country_code => Report::COUNTRY_CODE_USA)
    @voice_mail_mock = mock_model(VoiceMail, :null_object => true, :phone => '4152795555', :phone? => true)
    @report.stub!(:voice_mail).and_return(@voice_mail_mock)
  end

  describe "when looking up phone locale" do
    before do
      @phone_data = {"inputdata"=>[{"nxx"=>["279"], "npa"=>["415"]}], "prefixdata"=>[{"effdate"=>[{}], "switch"=>["CNCRCADOCM5"], "region"=>["CA"], "x"=>[{}], "discdate"=>[{}], "nxx"=>["279"], "ocn"=>["6010"], "rc-h"=>["8719"], "ilec-name"=>["PACIFIC BELL"], "lata"=>["722"], "rc"=>["San Francisco: Central DA"], "ilec-ocn"=>["9740"], "rc-v"=>["8492"], "company-name"=>["BLUE LICENSES HOLDING, LLC"], "npa"=>["415"]}]}
      XmlSimple.stub!(:xml_in).and_return(@phone_data)
    end

    it "should build url using phone number" do
      url = @report.local_calling_guide_url("4152790322")
      url.should == "http://www.localcallingguide.com/xmlprefix.php?npa=415&nxx=279"
    end
    
    it "should handle unknown sender" do
      @report.local_calling_guide_url("unknown sender").should be_nil
    end

    it "should set the phone city and state" do
      @report.lookup_phone_locale
      @report.phone_city.should == "San Francisco: Central DA"
      @report.phone_state.should == "CA"
    end
  end

  describe "when created" do
    before do
      @events_data = [{"City"=>"Scottsdale", "Status"=>nil, "Zip"=>nil, "Longitude"=>"-122.222222", "Latitude"=>"88.888888", "Event_Name"=>"Scottsdale Moms Meet Up to Stop Global Warming", "State"=>"AZ", "Maximum_Attendees"=>"0", "Address"=>"TBA", "key"=>"1202"}, {"City"=>"Tucson", "Status"=>nil, "Zip"=>nil, "Longitude"=>"0.000000", "Latitude"=>"0.000000", "Event_Name"=>"Arizona Moms and Families Support Global Warming Solutions", "State"=>"AZ", "Maximum_Attendees"=>"0", "Address"=>"SAFEWAY in Tucson--Final Location TBA", "key"=>"1295"}]
      @campaign_mock = mock_model(Campaign, :events => @events_data) 
      @report.stub!(:campaign).and_return(@campaign_mock)
      @geo = mock('geo', :lat => "77.777", :lng => "-111.111", :success => true)
      GeoKit::Geocoders::MultiGeocoder.stub!(:geocode).and_return(@geo)
    end
   
    def act!
      @report.save
    end

    it "should geocode the report if no event is selected" do
      act!
      @report.latitude.should == @geo.lat.to_f
      @report.longitude.should == @geo.lng.to_f
    end

    it "should use the events lat/lng if event is selected" do
      @report.event_id = @events_data.first["key"]
      act!
      @report.latitude.should == @events_data.first["Latitude"].to_f
      @report.longitude.should == @events_data.first["Longitude"].to_f
    end

    it "should set lat/lng to nil if no event is selected and city/state not specified" do
      act!
      @report.event_id = nil
      @report.city = ""
      @report.state = ""
      act!
      @report.latitude.should == nil
      @report.longitude.should == nil
    end

    it "should set file status to 'tagged and geocoded' if report has been tagged and geocoded" do
      act!
      @report.file_status.should == "tagged_and_geocoded"
    end
  end
end
