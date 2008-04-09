# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include AuthenticatedSystem
  before_filter :login_from_cookie
  before_filter :set_site, :set_campaign

  def set_site
    Site.current = Site.find_by_host(request.host)
    unless Site.current
      render :string => "Could not find #{request.host}."
    end
  end

  def set_campaign
    campaigns = Site.current.campaigns
    @campaign = campaigns.find_by_permalink(params[:permalink]) || 
                campaigns.current || campaigns.first
  end
end
