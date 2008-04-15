class UseCountryCodes < ActiveRecord::Migration
  def self.up
    rename_column :reports, :country, :country_code
    change_column :reports, :country_code, :integer
    change_column_default :reports, :country_code, Report::COUNTRY_CODE_USA
    Report.find(:all).each do |r|
      r.country_code = Report::COUNTRY_CODE_USA
      r.save
    end
  end

  def self.down
    rename_column :reports, :country_code, :country
  end
end
