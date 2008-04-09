class AddPermalink < ActiveRecord::Migration
  def self.up
    add_column :campaigns, :permalink, :string
    add_column :campaigns, :current, :boolean
  end

  def self.down
    remove_column :campaigns, :permalink
    remove_column :campaigns, :current
  end
end
