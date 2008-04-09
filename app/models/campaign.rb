class Campaign < ActiveRecord::Base
  belongs_to :site
  has_many :reports, :order => "reports.created_at DESC"
  has_many :users
end
