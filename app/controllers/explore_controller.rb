class ExploreController < ApplicationController
  before_filter :confirm_logged_in
  def index
    @users=User.order('users.email ASC').where(:editor =>true )
    #@contents = Content.order("contents.title ASC").where(:privacy => true, :editor => true)
  end
  
  def everything
    @user=User.find(session[:user_id])
    @contents = Content.order("contents.title ASC").where(:privacy => true)
  end

  def add
    content=Content.new
    oldcontent=Content.find(params[:id])
    content=oldcontent.dup
    content.avatar=oldcontent.avatar
    content.privacy=false
    content.user_id=session[:user_id]
    content.save
    redirect_to(:action => 'everything')
  end
  
  def upvote
    @user=User.find(params[:user_id])
    @content=Content.find(params[:id])
    
    if @user.flagged?(@content, :upvote)
         @user.unflag(@content, :upvote)     
    else 
        @user.flag(@content, :upvote)
    end
    redirect_to :action=>"everything"
  end

  def usersprofile
    @content = Content.find(params[:id])
    @other_user = User.find(@content.user_id)
    @contents = Content.order("contents.title ASC").where(:privacy => true, :user_id => @content.user_id)
    @user= User.find(session[:user_id])
  end
end
