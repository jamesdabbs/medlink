class Request < ActiveRecord::Base
  include Concerns::UserScope

  has_many :orders
  accepts_nested_attributes_for :orders, allow_destroy: false

  def self.due_date created_at
    created_at.at_beginning_of_month.next_month.strftime "%B %d"
  end
end
