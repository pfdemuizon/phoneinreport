class Report < ActiveRecord::Base
  belongs_to :campaign
  has_one :voice_mail
  #acts_as_mappable 
end
