class ExploreController < ApplicationController
  before_filter :confirm_logged_in

  def index
    @uptotal=0
    @contents1 = Content.order("contents.created_at DESC").where(:user_id => session[:user_id])
    @contents1.each do |content|#Calculate total upvotes
      @uptotal+=content.flaggings.size
      content.update_attributes(:upvotes=>content.flaggings.size)
    end
    @count=0
    @public=""
    @user=User.find(session[:user_id])
    if params[:filter]=="e" #Editors
      @users=User.order("users.email ASC").where(:editor=>true)
    elsif params[:filter]=="f" #Following only shows the people the current user is following
      @users=@user.followed_users
    elsif params[:filter]=="p" #Public doesn not show editors or thought leaders
      @users=User.order("users.email ASC").where(:editor=>false,:thought_leader=>false)
      @public="p"
    else #Explore shows thought_leader content only by default
      @users=User.order("users.email ASC").where(:thought_leader=>true)
    end
  end

  def add
    content=Content.new
    oldcontent=Content.find(params[:id])
    content=oldcontent.dup
    content.tag_list = oldcontent.tag_list
    content.avatar=oldcontent.avatar
    content.privacy=false
    content.user_id=session[:user_id]
    if content.save
      flash[:notice]="You've saved the content to your catalogue!"
    else
      flash[:notice]="Did not save."
    end
    # redirect_to(:action => 'index')
    redirect_to(:back)
  end
  
  def upvote
    @user=User.find(params[:user_id])
    @content=Content.find(params[:id])
    
    if @user.flagged?(@content, :upvote)
         @user.unflag(@content, :upvote)     
    else 
        @user.flag(@content, :upvote)
    end
    # redirect_to :action=>"index",:filter=>params[:filter]
    redirect_to(:back)
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
