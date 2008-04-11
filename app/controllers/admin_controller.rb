class AdminController < ApplicationController
  layout 'admin'
  before_filter :login_required, :except => :login
  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:email], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default(:permalink => @campaign.permalink, :controller => '/admin/reports', :action => 'index')
      flash[:notice] = "Logged in successfully"
    else
      flash[:notice] = "Login failed"      
    end
  end

  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(root_url)
  end
  
protected
  def authorized?
    return true if current_user.admin?
    flash[:notice] = "Must be an administrator to access this section."
    return false
  end

  def access_denied
    respond_to do |accepts|
      accepts.html do
        store_location
        redirect_to :controller => '/admin', :action => 'login'
      end
      accepts.xml do
        headers["Status"]           = "Unauthorized"
        headers["WWW-Authenticate"] = %(Basic realm="Web Password")
        render :text => "Could't authenticate you", :status => '401 Unauthorized'
      end
    end
    false
  end  
end
