class Api::V1::ResponsesController < Api::V1::BaseController
  def index
    @responses = ResponseHistory.new(
      for_user: current_user,
      type:     params[:type],
      since:    params[:since]
    ).responses
  end
end
