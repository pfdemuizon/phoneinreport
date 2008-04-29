class Admin::ReportsController < AdminController
  active_scaffold :report do |config|
    config.columns.add :country
    config.list.columns = [:created_at, :event_id, :file_status, :phone, :voice_mail, :latitude, :longitude, :city, :state, :country]
    config.update.columns = [:voice_mail, :created_at, :file_status, :reporter_name, :phone, :event_id, :city, :state, :country_code, :notes]
    config.list.sorting = [{:file_status => :asc}, {:created_at => :desc}]
  	config.actions.exclude :create

    config.columns[:file_status].label = "Report status"
    config.columns[:reporter_name].label = "Person's name"
  end

  skip_before_filter :login_required, :only => :feed
  def feed 
    @reports = @campaign.reports.find(:all, :conditions => ["file_status = ? OR file_status = ?", "tagged", "tagged_and_geocoded"])
    respond_to do |format|
      format.xml {render :xml => @reports.to_xml(:methods => [:voice_mail_url], :except => [:phone_city, :phone_state, :reporter_email])}
    end
  end

  def conditions_for_collection
    ['campaign_id = ?', @campaign.id]
  end
end
