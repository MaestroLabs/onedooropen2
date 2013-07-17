class ExploreController < ApplicationController
  before_filter :confirm_logged_in
  def index
    @users=User.order('users.email ASC').where(:editor =>true )
    #@contents = Content.order("contents.title ASC").where(:privacy => true, :editor => true)
  end
  
  def index
    @count=0
    @public=""
    @user=User.find(session[:user_id])
    @contents = ""
    if params[:filter]=="e"
      @users=User.order("users.email ASC").where(:editor=>true)
    elsif params[:filter]=="f"
      @users=@user.followed_users
    elsif params[:filter]=="p"
      @users=User.order("users.email ASC").where(:editor=>false,:thought_leader=>false)
      @public="p"
    else      
      @users=User.order("users.email ASC").where(:thought_leader=>true)
    end
  end

  def add
    content=Content.new
    oldcontent=Content.find(params[:id])
    content=oldcontent.dup
    content.avatar=oldcontent.avatar
    content.privacy=false
    content.user_id=session[:user_id]
    content.save
    redirect_to(:action => 'index')
  end
  
  def upvote
    @user=User.find(params[:user_id])
    @content=Content.find(params[:id])
    
    if @user.flagged?(@content, :upvote)
         @user.unflag(@content, :upvote)     
    else 
        @user.flag(@content, :upvote)
    end
    redirect_to :action=>"index",:filter=>params[:filter]
  end

  def usersprofile
    @content = Content.find(params[:id])
    @other_user = User.find(@content.user_id)
    @contents = Content.order("contents.title ASC").where(:privacy => true, :user_id => @content.user_id)
    @user= User.find(session[:user_id])
  end
  
   def tagged
     @count=0
    if params[:tag].present? 
      @tagname=params[:tag]
      @contents = Content.tagged_with(params[:tag]).where(:privacy => true).page(params[:page]).per_page(12)
    else 
      @contents = Content.postall.where(:privacy => true)
    end
    #render 'shared/tagged'  
  end
end
