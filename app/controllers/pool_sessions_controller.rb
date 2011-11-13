class PoolSessionsController < ApplicationController
  # GET /sessions
  # GET /sessions.xml
  def index
    @sessions = PoolSession.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sessions }
    end
  end

  # GET /sessions/1
  # GET /sessions/1.xml
  def show
    @session = PoolSession.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @session }
    end
  end

  # GET /sessions/new
  # GET /sessions/new.xml
  def new
    @session = PoolSession.new
    @users = User.all
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @session }
    end
  end

  # GET /sessions/1/edit
  def edit
    @session = PoolSession.find(params[:id])
  end

  # POST /sessions
  # POST /sessions.xml
  def create
    @session = PoolSession.new(params[:session])
    if @session.player1 == @session.player2
      flash[:error] = "You must specifify 2 separate players in a session"
      render :action => "new" 
    else
      respond_to do |format|
        if @session.save
          update_player_scores
          format.html { redirect_to home_index_path, :flash => { :notice => "Session Created Successfully" } }
          format.xml  { render :xml => @session, :status => :created, :location => @session }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @session.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /sessions/1
  # PUT /sessions/1.xml
  def update
    @session = PoolPoolSession.find(params[:id])
    if @session.player1 == @session.player2
      flash[:error] = "You must specifify 2 separate players in a session"
      render :action => "edit" 
    else
      respond_to do |format|
        if @session.update_attributes(params[:session])
          update_player_scores
          format.html { redirect_to(@session, :notice => 'Session was successfully updated.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @session.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /sessions/1
  # DELETE /sessions/1.xml
  def destroy
    @session = PoolSession.find(params[:id])
    @session.destroy

    respond_to do |format|
      format.html { redirect_to(sessions_url) }
      format.xml  { head :ok }
    end
  end#

  private
  def update_player_scores
    games = @session.player1_score + @session.player2_score + @session.draws
    @player1 = User.find(@session.player1)
    @player1.played = @player1.played + games
    @player1.won = @player1.won + @session.player1_score
    @player1.lost = @player1.lost + @session.player2_score
    @player1.draw = @player1.draw + @session.draws
    
    @player2 = User.find(@session.player2)
    @player2.played = @player2.played + games
    @player2.won = @player2.won + @session.player2_score
    @player2.lost = @player2.lost + @session.player1_score
    @player2.draw = @player2.draw + @session.draws

    @player1.save!
    @player2.save!

    message = @player1.pool_name + " Just played " + @player2.pool_name + " and "
    if @session.player1_score > @session.player2_score
      message = message + " won: "
    elsif @session.player1_score < @session.player2_score
      message = message + " lost: "
    else
      message = message + " drew: "
    end
    message = message + " " + @session.player1_score.to_s + " : " + @session.player2_score.to_s
    notification = Notification.new({:message => message})
    notification.save!
    update_elo_ratings
  end

  def update_elo_ratings
    player1  = Elo::Player.new(:rating => @player1.rating)
    player2  = Elo::Player.new(:rating => @player1.rating)

    @session.player1_score.times do
      player1.wins_from(player2)
    end

    @session.player2_score.times do
      player2.wins_from(player1)
    end

    @session.draws.times do
      player2.plays_draw(player1)
    end
    @player1.rating = player1.rating
    @player2.rating = player2.rating
    @player1.save!
    @player2.save!
  end
end
