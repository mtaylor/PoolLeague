class PoolSessionsController < ApplicationController
  # GET /sessions
  # GET /sessions.xml
  def index
    @pool_sessions = PoolSession.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pool_sessions }
    end
  end

  # GET /sessions/1
  # GET /sessions/1.xml
  def show
    @pool_session = PoolSession.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @pool_session }
    end
  end

  # GET /sessions/new
  # GET /sessions/new.xml
  def new
    @pool_session = PoolSession.new
    @users = User.all.select { |u| u.rating >= 0 }
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pool_session }
    end
  end

  # GET /sessions/1/edit
  def edit
    @pool_session = PoolSession.find(params[:id])
  end

  # POST /sessions
  # POST /sessions.xml
  def create
    @pool_session = PoolSession.new(params[:pool_session])
    if @pool_session.player1 == @pool_session.player2
      flash[:error] = "You must specifify 2 separate players in a session"
      render :action => "new" 
    else
      respond_to do |format|
        if @pool_session.save
          update_player_scores
          format.html { redirect_to home_index_path, :flash => { :notice => "Session Created Successfully" } }
          format.xml  { render :xml => @pool_session, :status => :created, :location => @pool_session }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @pool_session.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /sessions/1
  # PUT /sessions/1.xml
  def update
    @pool_session = PoolSession.find(params[:id])
    if @pool_session.player1 == @pool_session.player2
      flash[:error] = "You must specifify 2 separate players in a session"
      render :action => "edit" 
    else
      respond_to do |format|
        if @pool_session.update_attributes(params[:session])
          update_player_scores
          format.html { redirect_to(@pool_session, :notice => 'Session was successfully updated.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @pool_session.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /sessions/1
  # DELETE /sessions/1.xml
  def destroy
    @pool_session = PoolSession.find(params[:id])
    @pool_session.destroy

    respond_to do |format|
      format.html { redirect_to(sessions_url) }
      format.xml  { head :ok }
    end
  end#

  private
  def update_player_scores
    games = @pool_session.player1_score + @pool_session.player2_score
    @player1 = User.find(@pool_session.player1)
    @player1.played = @player1.played + games
    @player1.won = @player1.won + @pool_session.player1_score
    @player1.lost = @player1.lost + @pool_session.player2_score
    
    @player2 = User.find(@pool_session.player2)
    @player2.played = @player2.played + games
    @player2.won = @player2.won + @pool_session.player2_score
    @player2.lost = @player2.lost + @pool_session.player1_score

    @player1.save!
    @player2.save!

    message = @player1.full_name + " Just played " + @player2.full_name + " and "
    if @pool_session.player1_score > @pool_session.player2_score
      message = message + " won: "
    elsif @pool_session.player1_score < @pool_session.player2_score
      message = message + " lost: "
    else
      message = message + " drew: "
    end
    message = message + " " + @pool_session.player1_score.to_s + " : " + @pool_session.player2_score.to_s
    notification = Notification.new({:message => message})
    notification.save!

    p1m = @player1.full_name + "'s rating: " + @player1.rating.to_s + " => "
    p2m = @player2.full_name + "'s rating: " + @player2.rating.to_s + " => "
 
    update_elo_ratings

    p1m = p1m + @player1.rating.to_s
    p2m = p2m + @player2.rating.to_s

    p1n = Notification.new({:message => p1m})
    p2n = Notification.new({:message => p2m})
    p1n.save!
    p2n.save!
  end

  def update_elo_ratings
    player1  = Elo::Player.new(:rating => @player1.rating)
    player2  = Elo::Player.new(:rating => @player2.rating)

    p1score = @pool_session.player1_score
    p2score = @pool_session.player2_score

    while (p1score > 0 || p2score > 0)
      if p1score > 0
        player1.wins_from(player2)
        p1score = p1score - 1
      end

      if p2score > 0
        player2.wins_from(player1)
        p2score = p2score - 1
      end
    end

    @player1.rating = player1.rating
    @player2.rating = player2.rating
    @player1.save!
    @player2.save!
  end
end
