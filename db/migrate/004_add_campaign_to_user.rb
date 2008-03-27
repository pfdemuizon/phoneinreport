class AddCampaignToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :campaign_id, :integer
  end

  def self.down
    remove_column :users, :campaign_id
  end
end
