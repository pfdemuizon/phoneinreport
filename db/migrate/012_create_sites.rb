class CreateSites < ActiveRecord::Migration
  def self.up
    create_table :sites do |t|
      t.string :host
      t.string :s3_key
      t.string :s3_user
      t.timestamps
    end
    remove_column :campaigns, :s3_key
    remove_column :campaigns, :s3_user
    remove_column :campaigns, :host
    add_column :campaigns, :site_id, :integer
  end

  def self.down
    drop_table :sites
    add_column :campaigns, :s3_key, :string
    add_column :campaigns, :s3_user, :string
    add_column :campaigns, :host, :string
    remove_column :campaigns, :site_id
  end
end
