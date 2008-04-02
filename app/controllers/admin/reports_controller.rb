class Admin::ReportsController < AdminController
 
  active_scaffold :report do |config|
    config.list.columns = [:created_at, :phone, :voice_mail, :city, :state, :file_status]
    config.update.columns = [:voice_mail, :created_at, :phone, :city, :state, :voice_mail, :notes]
    config.list.sorting = {:created_at => :desc}
  	config.actions.exclude :create
  end

  skip_before_filter :login_required, :only => :feed
  def feed 
    @reports = @campaign.reports
    respond_to do |format|
      format.xml {render :xml => @reports.to_xml}
    end
  end
end
