class Campaign < ActiveRecord::Base
  has_many :reports, :order => "reports.created_at DESC"
  has_many :users
  validates_presence_of :host
end
