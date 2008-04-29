class LastFeedPull < ActiveRecord::Migration
  def self.up
    add_column :campaigns, :event_feed_cache_expire, :datetime
  end

  def self.down
    remove_column :campaigns, :event_feed_cache_expire
  end
end
