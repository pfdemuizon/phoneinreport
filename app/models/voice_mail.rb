class VoiceMail < ActiveRecord::Base
  belongs_to :report
  if RAILS_ENV == "production" # or RAILS_ENV == "development"
    has_attachment :storage => :s3, :content_type => ['audio/wav', 'audio/mp3'], :processor => :mp3_encoder
    #self.attachment_options = AttachmentOptions.new(attachment_options)
  else
    has_attachment :storage => :file_system, :content_type => ['audio/wav', 'audio/mp3'], :processor => :mp3_encoder
  end
  validates_as_attachment 

  def initialize(email=nil)
    super
    return unless email
    self.created_at = email.date.to_time
    self.phone = parse_phone(email.subject)
    self.max_email_ref_num = parse_max_email_ref_num(email.body)
    # def uploaded_data=() is provided by attachment_fu
    # copies over content_type, filename, and data-payload
    self.uploaded_data = detach_attachment(email)
  end

  protected

  def parse_phone(subject)
    subject =~ /MaxEmail voice message from (\d+)/
    $1 ? $1 : "unknown sender"
  end
 
  def parse_max_email_ref_num(body)
    body =~ /The reference number for this message is (\d+-\w+)./
    $1 ? $1 : "unknown reference number"
  end

  def detach_attachment(email)
    if email.has_attachments? 
      # just grab the first wav file attachment, there shouldn't be 
      # any other attachments, if there are, silently ignore them
      email.attachments.detect {|a| a.content_type == "audio/wav"}
    end
  end
end
