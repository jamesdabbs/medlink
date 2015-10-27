class Api::V1::RequestsController < Api::V1::ApiController
  before_action { request.format = :json }

  def index
    @requests = current_user.requests
  end

  def create
    rc = RequestCreator.new current_user, params
    authorize rc.request

    if rc.save
      render json: { status: :ok }
    else
      render json: { error: rc.error_message }, status: 422
    end
  end
end
