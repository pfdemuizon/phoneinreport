class VoiceMail < ActiveRecord::Base
  belongs_to :report
  if RAILS_ENV == "production" or RAILS_ENV == "development"
    has_attachment :storage => :s3, :content_type => ['audio/wav', 'audio/mp3'], :processor => :mp3_encoder
    #self.attachment_options = AttachmentOptions.new(attachment_options)
  else
    has_attachment :storage => :file_system, :content_type => ['audio/wav', 'audio/mp3'], :processor => :mp3_encoder
  end
  validates_as_attachment
end
