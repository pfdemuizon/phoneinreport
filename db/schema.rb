# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 14) do

  create_table "campaigns", :force => true do |t|
    t.string   "event_feed_url"
    t.string   "s3_bucket"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.integer  "site_id"
    t.string   "permalink"
    t.boolean  "current"
  end

  create_table "mail_configs", :force => true do |t|
    t.integer  "campaign_id"
    t.string   "server_type"
    t.string   "server"
    t.string   "username"
    t.string   "password"
    t.integer  "port"
    t.boolean  "ssl"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reports", :force => true do |t|
    t.integer  "event_id"
    t.integer  "campaign_id"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "phone"
    t.string   "phone_city"
    t.string   "phone_state"
    t.string   "file_status"
    t.string   "reporter_name"
    t.string   "reporter_email"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string "title"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["role_id", "user_id"], :name => "unique_index_on_role_id_and_user_id"

  create_table "sites", :force => true do |t|
    t.string   "host"
    t.string   "s3_key"
    t.string   "s3_user"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.integer  "campaign_id"
  end

  create_table "voice_mails", :force => true do |t|
    t.integer  "size"
    t.string   "content_type"
    t.string   "filename"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "max_email_ref_num"
    t.integer  "report_id"
    t.string   "type"
  end

end
