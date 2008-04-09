class Report < ActiveRecord::Base
  belongs_to :campaign
  has_one :voice_mail
  has_one :reporter, :class_name => 'User'
  acts_as_mappable 
  before_validation :geocode_address
 
  def address
    [self.city, self.state].join(', ')
  end

protected
  def geocode_address
    geo = GeoKit::Geocoders::MultiGeocoder.geocode(address)
    errors.add(:address, "Could not Geocode address") if !geo.success
    self.latitude, self.longitude = geo.lat, geo.lng if geo.success
  end
end
