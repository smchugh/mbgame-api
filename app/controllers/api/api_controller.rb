class Api::ApiController < ActionController::Base
  private

  def authenticate
    authenticate_or_request_with_http_token do |token, options|
      @user = User.where(api_token: token).where('api_token_expiration > ?', DateTime.current).first
    end
  end
end
