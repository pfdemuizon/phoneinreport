class Campaign < ActiveRecord::Base
  belongs_to :site
  has_many :reports, :order => "reports.created_at DESC"
  has_many :users
  has_one :mail_config
  validates_associated :mail_config
  cattr_accessor :current


  # do some local caching of event feed to avoid time-consuming 
  # pull of events feed.  this only works in production mode 
  # where config.cache_classes = true 
  @@event_feed_cache = nil
  def events
    if @@event_feed_cache.nil? || event_feed_cache_expired?
      return unless self.event_feed_url
      @@event_feed_cache = Hash.from_xml(open(self.event_feed_url))
      return unless @@event_feed_cache
      update_attribute(:event_feed_cache_expire, 1.minute.from_now)
    end
    @@event_feed_cache['data']['event']['item']
  end

protected
  def event_feed_cache_expired?
    return true unless self.event_feed_cache_expire
    self.event_feed_cache_expire < Time.now
  end
end
