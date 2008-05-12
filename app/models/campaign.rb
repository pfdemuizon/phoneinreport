class Campaign < ActiveRecord::Base
  belongs_to :site
  has_many :reports, :order => "reports.created_at DESC"
  has_many :users
  has_one :mail_config
  validates_associated :mail_config
  cattr_accessor :current

  # do some local caching of events to avoid time-consuming pull 
  # from event feed.  this only works in production mode where 
  # config.cache_classes = true 
  @@events_cache = nil
  def events
    return [] unless self.event_feed_url
    if @@events_cache.nil? || events_cache_expired?
      require 'open-uri' # for open
      events = Hash.from_xml(open(self.event_feed_url).read)
      return [] unless events['data']['event']['item']
      @@events_cache = events
      update_attribute(:events_cache_expire, 1.hour.from_now)
    end
    @@events_cache['data']['event']['item']
  end

protected
  def events_cache_expired?
    return true unless self.events_cache_expire
    Time.now > self.events_cache_expire
  end
end
