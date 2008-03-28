class AddTypeToVoiceMail < ActiveRecord::Migration
  def self.up
    add_column :voice_mails, :type, :string
  end

  def self.down
    remove_column :voice_mails, :type
  end
end
