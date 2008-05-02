require File.dirname(__FILE__) + '/../spec_helper'

describe Site do
  before do
    @site = Site.new(:host => "echo.radicaldesigns.org")
  end

  it "should be valid" do
    @site.should be_valid
  end
end
