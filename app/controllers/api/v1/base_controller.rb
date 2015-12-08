class Api::V1::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :json_format

  private

  def json_format
    request.format = :json
  end

  def error msg, status: 400
    render json: { error: msg }, status: status
  end

  def invalid obj
    render json: { error: "Invalid", failures: obj.errors.full_messages }, status: 422
  end
end
