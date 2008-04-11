class Campaign < ActiveRecord::Base
  belongs_to :site
  has_many :reports, :order => "reports.created_at DESC"
  has_many :users
  has_one :mail_config
  validates_associated :mail_config
  cattr_accessor :current
end
