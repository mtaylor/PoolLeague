class HomeController < ApplicationController
  def index
    @users = User.all(:order => 'rating DESC')
    @notifications = Notification.all(:order => 'created_at DESC', :limit => 15)
  end

  def rules
    
  end

  def elo
    
  end
end
