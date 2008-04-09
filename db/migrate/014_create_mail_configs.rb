class CreateMailConfigs < ActiveRecord::Migration
  def self.up
    create_table :mail_configs do |t|
      t.integer :campaign_id
      t.string :server_type
      t.string :server
      t.string :username
      t.string :password
      t.integer :port
      t.boolean :ssl
      t.timestamps
    end
    remove_column :campaigns, :pop_server
    remove_column :campaigns, :pop_user
    remove_column :campaigns, :pop_pw
    remove_column :campaigns, :pop_port
  end

  def self.down
    drop_table :mail_configs
    add_column :campaigns, :pop_server, :string
    add_column :campaigns, :pop_user, :string
    add_column :campaigns, :pop_pw, :string
    add_column :campaigns, :pop_port, :integer
  end
end
