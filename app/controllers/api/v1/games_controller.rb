class Api::V1::GamesController < Api::ApiController
  respond_to :json
  before_action :authenticate
  before_action :set_game, only: [:show, :update, :destroy]

  # GET /games
  # GET /games.json
  def index
    @games = Game.filtered_games(filters_from_params)
  end

  # GET /games/1
  # GET /games/1.json
  def show
  end

  # POST /games
  # POST /games.json
  def create
    # Try to prevent a user from having more than one active game
    active_game = @user.active_game
    if active_game
      @game = active_game
    else
      # If there is no active game, create a new one
      piles = []
      game_creation_params[:piles].each do |num_beans|
        piles.append num_beans
      end
      @game = Game.new({piles: piles, human_player_id: @user.id, status: Game::STATUS_ACTIVE})
    end

    if @game.save
      render :show, status: :created
    else
      render json: @game.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update
    if @game.status != Game::STATUS_COMPLETE
      if @user.id == @game.active_player_id
        pile_id = turn_params[:pile].to_i
        num_beans = turn_params[:beans].to_i
        if @game.piles[pile_id] >= num_beans
          turn_params[:player_id] = @user.id
          turn = Turn.new(turn_params)
          @game.turns.append(turn)
          @game.piles[pile_id] -= num_beans

          if @game.is_winner?
            @game.complete_game!
          end

          @game.advance_active_player!

          if @game.save
            render :show, status: :ok
          else
            render json: @game.errors, status: :unprocessable_entity
          end
        else
          @beans = num_beans
          @pile = pile_id
          render :error_beans, status: :unprocessable_entity
        end
      else
        render :error_player_id, status: :unprocessable_entity
      end
    else
      render :error_completed_game, status: :unprocessable_entity
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game.destroy
    head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def turn_params
      params.require(:game).permit(:pile, :beans)
    end

    def game_creation_params
      params.require(:game).permit(:piles => [])
    end

    def filters_from_params
      {
          user_id: @user.id,
          status: params[:status],
          is_active_player:  params[:is_active_player] ? params[:is_active_player].to_bool : nil,
          is_winner: params[:is_winner] ? params[:is_winner].to_bool : nil
      }
    end
end
