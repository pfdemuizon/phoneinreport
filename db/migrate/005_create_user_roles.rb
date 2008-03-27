class CreateUserRoles < ActiveRecord::Migration
  def self.up
    create_table :roles, :force => true do |t|
      t.string :title
    end
    create_table :roles_users, :id => false, :force => true do |t|
      t.integer :role_id
      t.integer :user_id
    end
    add_index "roles_users", ["role_id", "user_id"], :name => "unique_index_on_role_id_and_user_id"
  end

  def self.down
    drop_table :roles
    drop_table :roles_users
  end
end
