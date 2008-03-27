class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :campaign_id 
      t.string :password
      t.string :email
      t.string :first_name
      t.string :last_name
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
