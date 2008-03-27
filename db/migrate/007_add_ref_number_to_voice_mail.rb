class AddRefNumberToVoiceMail < ActiveRecord::Migration
  def self.up
    add_column :voice_mails, :max_email_ref_num, :string
  end

  def self.down
    remove_column :voice_mails, :max_email_ref_num
  end
end
