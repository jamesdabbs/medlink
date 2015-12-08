json.responses @responses.includes(:supplies, user: :phones) do |response|
  json.user do
    json.(response.user, :first_name, :last_name, :location, :email)
    json.phones response.user.phones.map(&:number)
  end
  json.orders response.orders do |order|
    json.(order, :request_id, :created_at)
    json.duplicate order.duplicated_at.present?
    json.response  order.delivery_method.try(:title)
    json.supply    order.supply.name
  end
  json.instructions response.extra_text
  #json.status do
  #  json.state response.status
  #  json.at    response.at
  #end
end
