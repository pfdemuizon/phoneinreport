class Report < ActiveRecord::Base
  belongs_to :campaign
  has_one :voice_mail, :dependent => :destroy
  has_one :reporter, :class_name => 'User'
  acts_as_mappable 
  before_validation :geocode_address
  def address
    (self.city and self.state) ? [self.city, self.state].join(', ') : nil
  end

protected
  def geocode_address
    return unless address  # avoid unnecessary geocode if address not set
    geo = GeoKit::Geocoders::MultiGeocoder.geocode(address)
    errors.add(:address, "Could not Geocode address") if !geo.success
    self.latitude, self.longitude = geo.lat, geo.lng if geo.success
  end
end
