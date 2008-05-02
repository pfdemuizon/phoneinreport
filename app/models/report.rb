class Report < ActiveRecord::Base
  FILE_STATUS = %w(pending tagged tagged_and_geocoded junk) 
  COUNTRY_CODE_USA = CountryCodes.find_by_name('United States of America')[:numeric]

  belongs_to :campaign
  has_one :voice_mail, :dependent => :destroy
  has_one :reporter, :class_name => 'User'

  acts_as_mappable 
  before_validation :geocode_address
  before_save :lookup_phone_locale

  def address
    (self.city? and self.state? and self.country_code?) ? [self.city, self.state, self.country].join(', ') : nil
  end

  def country
    CountryCodes.find_by_numeric(self.country_code)[:name]
  end

  def voice_mail_url
    self.voice_mail.public_filename
  end

  require 'open-uri'
  def lookup_phone_locale
    phone = self.voice_mail.phone
    return unless phone
    data = XmlSimple.xml_in(open(local_calling_guide_url(phone)))
    if data['prefixdata'] && data['prefixdata'][0] 
      self.phone_city = data['prefixdata'][0]['rc'][0] if data['prefixdata'][0]['rc']
      self.phone_state = data['prefixdata'][0]['region'][0] if data['prefixdata'][0]['region']
    end
  end

protected
  def local_calling_guide_url(phone)
    uri = "http://www.localcallingguide.com/xmlprefix.php?npa=NPA&nxx=NXX"
    uri.gsub("NPA", phone[0..2]).gsub("NXX", phone[3..5])
  end

  def geocode_address
    return unless address  # avoid unnecessary geocode if address not set
    geo = GeoKit::Geocoders::MultiGeocoder.geocode(address)
    errors.add(:address, "Could not Geocode address") if !geo.success
    self.latitude, self.longitude = geo.lat, geo.lng if geo.success
  end
end
