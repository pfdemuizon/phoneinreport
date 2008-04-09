require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Report do
  before do
    @report = Report.new(:city => "Fremont", :state => "CA")

    @geo = mock('geo', :lat => "77.777", :lng => "-111.111", :success => true)
    GeoKit::Geocoders::MultiGeocoder.stub!(:geocode).and_return(@geo)
  end
  describe "when created" do
    it "should geocode the report" do
      @report.save
      @report.latitude.should == 77.777 && @report.longitude.should == -111.111
    end
    it "should upload voice mail to s3" do
    end
    it "should look-up city and state from phone number" do
    end
  end
end
