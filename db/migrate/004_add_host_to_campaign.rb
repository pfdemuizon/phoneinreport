class AddHostToCampaign < ActiveRecord::Migration
  def self.up
    add_column :campaigns, :host, :string
  end

  def self.down
    remove_column :campaigns, :host
  end
end
