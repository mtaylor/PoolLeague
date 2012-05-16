class HomeController < ApplicationController
  def index
    @users = User.all(:order => 'rating DESC')
    @notifications = Notification.all(:order => 'created_at DESC', :limit => 10)
    if !mobile_device?
      if !current_user
        redirect :login
      else
        @pool_session = PoolSession.new
        render :mindex, :layout => nil
      end
    end
  end

  def login
    if !mobile_device?
      render :mlogin, :layout => nil
    else
      redirect :index
    end
  end

  def rules
  end

  def elo
  end
end
