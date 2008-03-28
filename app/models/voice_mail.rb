class VoiceMail < ActiveRecord::Base
  belongs_to :report
  if RAILS_ENV == "development" or RAILS_ENV == "test"
    has_attachment :storage => :file_system, :content_type => 'audio/wav'
  else
    has_attachment :storage => :s3, :content_type => 'audio/wav'
  end
  validates_as_attachment
end
