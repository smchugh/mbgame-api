class Api::V1::UsersController < Api::ApiController
  respond_to :json
  before_action :authenticate, except: [:auth, :create]

  # POST /users/auth.json
  def auth
    @user = User.get_authenticated(auth_params[:email], auth_params[:password])
    if @user
      # Attempt to create/update a token and send it back
      @user.set_auth

      if @user.save
        render :auth, status: :ok
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    else
      # Return user_not_found error
      render :error_auth, status: :not_found
    end
  end

  # POST /users/logout.json
  def logout
    # Expire the token
    @user.api_token_expiration = DateTime.current - 1.seconds
    if @user.save
      head :no_content
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1.json
  def show
  end

  # POST /users.json
  def create
    @user = User.new(creation_params)

    if @user.save
      render :show_with_auth, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1.json
  def update
    if @user.update(user_params)
      render :show, status: :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1.json
  def destroy
    @user.destroy
    head :no_content
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def creation_params
      params.require(:user).permit(:name, :email, :picture, :new_password, :new_password_confirmation)
    end

    def user_params
      params.require(:user).permit(:name, :email, :picture)
    end

    def auth_params
      params.require(:user).permit(:email, :password)
    end
end
