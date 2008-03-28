class AddReportIdToVoiceMail < ActiveRecord::Migration
  def self.up
    add_column :voice_mails, :report_id, :integer
  end

  def self.down
    remove_column :voice_mails, :report_id
  end
end
