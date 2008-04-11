class Admin::MailConfigController < AdminController
  active_scaffold :mail_config do |config|
    config.list.columns = [:server_type, :server, :port, :username, :ssl]
    config.update.columns = [:server_type, :server, :port, :username, :password, :ssl]
    config.list.sorting = {:created_at => :desc}
  	config.actions.exclude :create
  end

  # need to restart mail daemon whenever there is a change to mail_config
end
