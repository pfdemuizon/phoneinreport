class Report < ActiveRecord::Base
  belongs_to :campaign
  has_one :voice_mail
  has_one :reporter, :class_name => 'User'
  acts_as_mappable :auto_geocode => 
    {:field => :city_state, :error_message => 'Could not geocode address'}, 
    :lat_column_name => 'latitude', :lng_column_name => 'longitude'

  def city_state
    [self.city, self.state].join(', ')
  end
end
