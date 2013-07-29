class ExploreController < ApplicationController
  before_filter :confirm_logged_in
  before_filter :current_user

  def index
    @uptotal=0
     contents = Content.order("contents.created_at DESC").where(:user_id => session[:user_id])
     contents.each do |content|#Calculate total upvotes
       @uptotal+=content.flaggings.size
       content.update_attributes(:upvotes=>content.flaggings.size)
     end
    @count=0 #starts at 0 to create the first row-fluid
    @public=""
    @user=User.find(session[:user_id])
    if params[:filter]=="e" #Editors
      @users=User.where(:editor=>true)
    elsif params[:filter]=="f" #Following only shows the people the current user is following
      @users=@user.followed_users
    elsif params[:filter]=="p" #Public doesn not show editors or thought leaders
      @users=User.where(:editor=>false,:thought_leader=>false)
      @public="p"
    else #Explore shows thought_leader content only by default
      @users=User.where(:thought_leader=>true)
    end
  end
  
  def results
    if params[:filter]=="Name" && params[:search].present?
      @searchedterm = params[:search]
      @name=true
      @search = User.search do
        fulltext params[:search] do
        boost(2.0) { with(:thought_leader, true) }
        end
        #order_by :last_name, :asc
        order_by(:score, :desc)
       # with  :last_name, params[:search]
       # with :first_name, params[:search]
        paginate(:per_page => 12, :page => params[:page])
      end
      @users=@search.results
    end
    
    @user=User.find(session[:user_id])
    @count=0
    if params[:search].present? && params[:filter]=="Tags"
      tags_array= params[:search].split(/ /)
   end
   @search = Content.search do
      fulltext params[:search] if params[:filter]=="Title"
      facet :tag_list
      order_by :upvotes, :desc
      order_by :updated_at, :desc
      with :privacy, true
      with(:tag_list).any_of(tags_array)if params[:search].present? && params[:filter]=="Tags"
      paginate(:per_page => 12, :page => params[:page])
   end
   @contents = @search.results
  end
  
  def following
    # @uptotal=0
    @user=User.find(session[:user_id])
    @other_users=@user.followed_users
    # @contents1 = Content.order("contents1.created_at DESC").where(:user_id => session[:user_id])
    # @contents1.each do |content|#Calculate total upvotes
      # @uptotal+=content.flaggings.size
      # content.update_attributes(:upvotes=>content.flaggings.size)
    # end
    @count=0
    
    
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
      flash[:error]="Unable to save content. Please try again."
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
