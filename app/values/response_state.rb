class ResponseState
  def initialize response
    determine response
    freeze
  end

  private

  def determine response
    if response.received_at.present?
      @state, @at = :received, response.received_at
    elsif response.cancelled_at.present?
      @state, @at = :cancelled, response.cancelled_at
    end
  end
end
