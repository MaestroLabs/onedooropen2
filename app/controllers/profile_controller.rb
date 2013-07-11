class ProfileController < ApplicationController
  before_filter :confirm_logged_in
  before_filter :find_user
    
  def show
     @contents = Content.order("contents.title ASC").where(:user_id => session[:user_id])
     @user=User.find(session[:user_id])
  end
  
  def addC
    @content=Content.new(:user_id=>session[:user_id])
  end
  
  def createC
    #Instantiate a new object using form parameters
    user=User.find(session[:user_id])
    @content= Content.new(params[:content])
    #Save the object
    @content.user_id=session[:user_id] 
    if @content.name==true
      @content.file_type="Anonymous"
    end
    if @content.name==false
      @content.file_type="#{user.first_name} #{user.last_name}"
    end
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
    user=User.find(session[:user_id])
    @content= Content.find(params[:id])
    #Save the object

    if @content.update_attributes(params[:content])
      #If save succeeds redirect to the list action
       if @content.name==true 
         @content.update_attributes(:file_type=>"Anonymous")
       end
       if @content.name==false
        @content.update_attributes(:file_type=>"#{user.first_name} #{user.last_name}")
       end
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
  
  def tagged
    @tagname=params[:tag]
    if params[:tag].present? 
      @contents = Content.tagged_with(params[:tag]).where(:user_id=>session[:user_id])
    else 
      @contents = Content.postall
    end  
  end
  
     def following
     @title = "Following"
     @user = User.find(params[:id])
     @users = @user.followed_users#.paginate(page: params[:page])
   end
 
   def followers
     @title = "Followers"
     @user = User.find(params[:id])
     @users = @user.followers#.paginate(page: params[:page])
   end
  
  
    def usersprofile
    #@content = Content.find(params[:id])
    @other_user = User.find(params[:id])
    @contents = Content.order("contents.title ASC").where(:privacy => true, :user_id => params[:id])
    @user= User.find(session[:user_id])
  end
  
    private
  
  def find_user
    if session[:user_id]
      @user = User.find_by_id(params[:user_id])
    end
  end

end
