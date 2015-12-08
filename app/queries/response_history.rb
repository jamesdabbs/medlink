class ResponseHistory
  def initialize for_user:, type: nil, since: nil
    @user  = for_user
    @type  = type  || "unarchived"
    @since = since || 3.months.ago
  end

  def responses
    @_responses ||= _type _since _responses
  end

  private

  def _responses
    if @user.pcv?
      @user.responses
    else
      @user.country.responses
    end
  end

  def _since scope
    scope.where("created_at > ?", @since)
  end

  def _type scope
    case @type.to_s
    when "archived"
      scope.where "responses.archived_at IS NOT NULL OR responses.cancelled_at IS NOT NULL"
    when "all"
      scope
    else # assume "unarchvied"
      scope.where received_at: nil, cancelled_at: nil
    end
  end
end
