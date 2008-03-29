class Admin::ReportsController < AdminController
  active_scaffold :report do |config|
    config.list.columns = [:created_at, :phone, :city, :state, :voice_mail]
    config.update.columns = [:voice_mail, :created_at, :phone, :city, :state, :voice_mail, :notes]
    config.list.sorting = {:created_at => :desc}
  end
end
