class ProfileController < ApplicationController
  before_filter :confirm_logged_in
  before_filter :find_user

  def show
     @uptotal=0
     @contents = Content.order("contents.created_at DESC").where(:user_id => session[:user_id]).page(params[:page]).per_page(12)
     @contents.each do |content|#Calculate total upvotes
       @uptotal+=content.flaggings.size
       content.upvotes=content.flaggings.size
     end
     @user=User.find(session[:user_id])
     @count=0
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
      # redirect_to(:action => 'show', :user_id => @content.user_id)
      redirect_to(:back)
    else
      #If save fails, redisplay the form so user can fix problems
      render('addC')
    end
  end
  
  def editC
    @user = User.find(session[:user_id])
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
  
  def deleteC
    @content = Content.find(params[:id])
  end
  
  def explodePineapple
     @content = Content.find(params[:id])
     if session[:user_id] == @content.user_id
       @content.destroy
       flash[:notice]="This post has been deleted."
     end
     # redirect_to(:action => 'show',:user_id=>@content.user_id)
     redirect_to(:back)
  end
  
  def tagged
    @count=0
    @tagname=params[:tag]
    if params[:tag].present? 
      @contents = Content.tagged_with(params[:tag]).where(:user_id=>session[:user_id]).page(params[:page]).per_page(12)
    else 
      @contents = Content.postall.page(params[:page]).per_page(12)
    end  
  end
  
   def following
     @count = 0
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
    @uptotal=0
    @other_user = User.find(params[:id])
    @contents = Content.order("contents.title ASC").where(:privacy => true, :user_id => params[:id], :name => false)
    @user= User.find(session[:user_id])
  end
  
    def upvote
    @user=User.find(session[:user_id])
    @content=Content.find(params[:id])
    
    if @user.flagged?(@content, :upvote)
         @user.unflag(@content, :upvote)     
    else 
        @user.flag(@content, :upvote)
    end
    # redirect_to :action=>"usersprofile",:id=> params[:user_id]
    redirect_to(:back)
  end

  
    private
  
  def find_user
    if session[:user_id]
      @user = User.find_by_id(params[:user_id])
    end
  end

end
