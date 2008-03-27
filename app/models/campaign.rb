class Campaign < ActiveRecord::Base
  has_many :reports
  has_many :users

  validates_presence_of :host
end
