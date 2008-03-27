class Report < ActiveRecord::Base
  belongs_to :campaign
  has_one :voice_mail
end
