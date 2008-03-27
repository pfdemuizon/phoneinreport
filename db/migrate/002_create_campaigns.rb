class CreateCampaigns < ActiveRecord::Migration
  def self.up
    create_table :campaigns do |t|
      t.string :event_feed_url
      t.string :pop_server
      t.string :pop_user
      t.string :pop_pw
      t.integer :pop_port
      t.string :s3_bucket
      t.string :s3_key
      t.string :s3_user
      t.timestamps
    end
  end

  def self.down
    drop_table :campaigns
  end
end
