class DefaultFileStatus < ActiveRecord::Migration
  def self.up
    change_column_default(:reports, :file_status, :default => "pending")
    Report.find(:all).each {|r| r.file_status = "pending"; r.save}
  end

  def self.down
    # cannot use change_column_default to change default back to nil
  end
end
