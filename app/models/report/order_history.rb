class Report::OrderHistory < Report
  def initialize orders
    self.rows = orders.includes :supply, :response, :user => :phones
  end

  def format order
    supply          = order.supply
    response        = order.response
    delivery_method = order.delivery_method
    user            = order.user
    phone           = user.primary_phone

    {
      "Placed"       => order.created_at,
      "Country"      => user.country.name,
      "PCV ID"       => user.pcv_id,
      "First Name"   => user.first_name,
      "Last Name"    => user.last_name,
      "Email"        => user.email,
      "Phone"        => phone.try(:number),
      "Item"         => supply.name,
      "Location"     => user.location,
      "Responded"    => response.try(:created_at),
      "Response"     => delivery_method.try(:name),
      "Instructions" => response.try(:extra_text)
    }
  end
end
