class CreateVoiceMails < ActiveRecord::Migration
  def self.up
    create_table :voice_mails do |t|
      t.integer :size
      t.string :content_type
      t.string :filename
      t.timestamps
    end
  end

  def self.down
    drop_table :voice_mails
  end
end
