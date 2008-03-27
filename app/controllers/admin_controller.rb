class AdminController < ApplicationController
  layout 'admin'
  before_filter :login_required, :except => :login
  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:email], params[:password])
    #debugger
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default(:controller => '/admin/operator', :action => 'index')
      flash[:notice] = "Logged in successfully"
    end
  end

=begin
  def signup
    @user = User.new(params[:user])
    return unless request.post?
    @user.save!
    self.current_user = @user
    redirect_back_or_default(:controller => '/account', :action => 'index')
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end
=end
  
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
    flash[:notice] = "Mustbe an administrator to access this section."
    return false
  end
end
