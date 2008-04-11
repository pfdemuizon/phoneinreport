class AttachmentOptions
  def initialize(defaults = {})
    @scoped_attachment_options = {}
    @global_attachment_options = {
      :storage => :s3,
      :max_size => 2.megabytes,
      :size => 1..2.megabytes
    }
    @default_attachment_options = defaults
  end
  def [](option)
    @scoped_attachment_options[Site.current.id] ||= {:bucket_name => Campaign.current.s3_bucket}
    @global_attachment_options[option] || @scoped_attachment_options[Site.current.id][option] || @default_attachment_options[option]
  end
  def []=(option, value)
    @scoped_attachment_options[Site.current.id] ||= {}
    @scoped_attachment_options[Site.current.id][option] = value
  end
end
