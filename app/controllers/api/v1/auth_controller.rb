class Api::V1::AuthController < Api::V1::ApiController
  skip_before_action :api_authenticate!, only: [:login]

  def login
    user = User.find_for_authentication(email: params[:email])
    if user.valid_password?(params[:password])
      user.ensure_secret_key!
      render json: { secret_key: user.secret_key }
    else
      render json: { error: "Invalid username or password" }, status: :unauthorized
    end
  end
end
