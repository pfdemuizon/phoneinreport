class RemoveFeedFromCacheExpired < ActiveRecord::Migration
  def self.up
    rename_column :campaigns, :event_feed_cache_expire, :events_cache_expire
  end

  def self.down
    rename_column :campaigns, :events_cache_expire, :event_feed_cache_expire
  end
end
