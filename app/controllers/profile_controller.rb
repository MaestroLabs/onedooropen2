class ProfileController < ApplicationController
  before_filter :confirm_logged_in
  before_filter :find_user
    
  def show
     @contents = Content.order("contents.title ASC").where(:user_id => session[:user_id])
  end
  
  def addC
    @content=Content.new(:user_id=>session[:user_id])
  end
  
  def createC
    #Instantiate a new object using form parameters
    @content= Content.new(params[:content])
    #Save the object
    @content.user_id=session[:user_id]  
    if @content.save
      #If save succeeds redirect to the list action
      flash[:notice]="Content Added."
      redirect_to(:action => 'show', :user_id => @content.user_id)
    else
      #If save fails, redisplay the form so user can fix problems
      render('addC')
    end
  end
  
  def editC
    @content = Content.find(params[:id])
  end
  
  def updateC
    #Instantiate a new object using form parameters
    @content= Content.find(params[:id])
    #Save the object
    if @content.update_attributes(params[:content])
      #If save succeeds redirect to the list action
      flash[:notice]="Content Updated."
      redirect_to(:action => 'show',:user_id => @content.user_id)
    else
      #If save fails, redisplay the form so user can fix problems
      render('editC')
    end
  end
  
  def showC
     @content = Content.find(params[:id])
  end
  
  def deleteC
    @content = Content.find(params[:id])
  end
  
  def destroyC
     @content = Content.find(params[:id])
     @content.destroy
     flash[:notice]="Content destroyed."
     redirect_to(:action => 'show',:user_id=>@content.user_id)
  end
  
    private
  
  def find_user
    if session[:user_id]
      @user = User.find_by_id(params[:user_id])
    end
  end

end
