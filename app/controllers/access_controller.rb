class AccessController < ApplicationController
  before_filter :confirm_logged_in, :except => [:attempt_login, :logout, :index,:register,:createuser,:activate,:resendtoken,:confirmtoken]
  
  def index
    #display login form
  end
  
  def register
    @user=User.new
  end
  
  def createuser
    #Instantiate a new object using form parameters
    @user= User.new(params[:user])
    #@user.activated=false
    #Save the object
    if @user.save
      #If save succeeds redirect to the list action
      UserMailer.registration_confirmation(@user).deliver
      flash[:notice]="Email Activation Sent."
      redirect_to(:action => 'activate')
    else
      #If save fails, redisplay the form so user can fix problems
      render('register')
    end
  end
  
    def attempt_login
    authorized_user = User.authenticate(params[:email], params[:password])
    if !authorized_user
      flash[:notice] = "Invalid username/password combination."
      redirect_to(:action => 'index')
    elsif authorized_user && authorized_user.activated == false || authorized_user.activated == "f"
       flash[:notice] = "You have not activated your account"
       redirect_to(:action => 'activate')
    elsif authorized_user && authorized_user.activated == true || authorized_user.activated == "t"
      session[:user_id]=authorized_user.id
      session[:email]=authorized_user.email
      flash[:notice] = "You are logged in"
      redirect_to(:controller => 'profile', :action => 'show',:user_id=>authorized_user.id)
    end 
  end
  
  def logout
      session[:user_id]=nil
      session[:email]=nil
      flash[:notice] = "Logged Out"
      redirect_to(:action => 'index')
  end
  
  def activate
    
  end
  
  def resendtoken
    @user=User.find_by_email(params[:email])
    UserMailer.registration_confirmation(@user).deliver
    flash[:notice]="Resent Email"
    redirect_to(:action => 'activate')
  end
  
  def confirmtoken
    activate_user = User.activate(params[:token])
    if activate_user
      activate_user.activated = true
      activate_user.save
      flash[:notice]="Account Activated"
      redirect_to(:action => 'index')
    else
      flash[:notice]="Invalid Token"
      redirect_to(:action => 'activate')
    end
  end
end