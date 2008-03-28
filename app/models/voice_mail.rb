class VoiceMail < ActiveRecord::Base
  belongs_to :report

  if RAILS_ENV == "development" or RAILS_ENV == "test"
    has_attachment :storage => :file_system, :content_type => ['audio/wav', 'audio/mp3'], :processor => :mp3_encoder
  else
    has_attachment :storage => :s3, :content_type => ['audio/wav', 'audio/mp3'], :processor => :mp3_encoder
  end
  validates_as_attachment
end
