class Draper::CollectionDecorator
  delegate :current_page, :total_pages, :total_count, :limit_value
end

class RosterUserPresenter < ApplicationPresenter
  decorates User
  delegate :id, :email, :first_name, :last_name, :phones

  def role
    if model.pcv?
      "PCV ##{model.pcv_id}"
    elsif model.pcmo?
      "PCMO"
    else
      "Admin"
    end
  end

  def location
    model.location.capitalize
  end
end
