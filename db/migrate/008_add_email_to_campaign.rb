class AddEmailToCampaign < ActiveRecord::Migration
  def self.up
    add_column :campaigns, :email, :string
  end

  def self.down
    remove_column :campaigns, :email
  end
end
