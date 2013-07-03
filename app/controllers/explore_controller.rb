class ExploreController < ApplicationController
  before_filter :confirm_logged_in
  def index
    @users=User.order('users.email ASC').where(:editor =>true )
    #@contents = Content.order("contents.title ASC").where(:privacy => true, :editor => true)
  end
  
  def everything
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

end
