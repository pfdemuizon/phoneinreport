class MovePhoneToVoiceMail < ActiveRecord::Migration
  def self.up
    add_column :voice_mails, :phone, :string
    Report.find(:all).each do |r|
      r.voice_mail.phone = r.phone
      r.voice_mail.save
    end
    remove_column :reports, :phone
    # type isn't getting used anywhere, just remove it
    remove_column :voice_mails, :type
  end

  def self.down
    add_column :reports, :phone, :string
    Report.find(:all).each do |r|
      r.phone = r.voice_mail.phone
      r.save
    end
    remove_column :voice_mails, :phone
    add_column :voice_mails, :type, :string
  end
end
