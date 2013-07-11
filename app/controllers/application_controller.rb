class ApplicationController < ActionController::Base
  protect_from_forgery
  protected
  
  def confirm_logged_in
    unless session[:email]
      flash[:notice] = "Please log in."
      redirect_to(:controller => 'access', :action => 'index')
      return false #halts the before_filter
     else
       return true
    end
  end
end
