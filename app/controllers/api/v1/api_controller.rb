class Api::V1::ApiController < ActionController::Base
  before_action :api_authenticate!
  before_action :hardcode_json

private

  def api_authenticate!
    @current_user = User.find_by_id(ApiAuth.access_id request)
    head(:unauthorized) unless @current_user && ApiAuth.authentic?(request, @current_user.secret_key)
  end

  def hardcode_json
    request.format = :json
  end
end
