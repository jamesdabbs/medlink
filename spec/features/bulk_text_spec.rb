require 'spec_helper'

describe "Bulk texting" do
  before :each do
    3.times do
      country = create :country
      user = create :user, country: country
      create :phone, user: user
    end

    @countries = Country.last 2

    @user = create :admin
    login @user

    visit admin_messages_path
  end

  it "can send to multiple countries", :worker do
    fill_in "sms_bulk_sender_body", with: "Test message"
    @countries.each do |c|
      select c.name, from: "sms_bulk_sender_country_ids"
    end
    click_button "Send"

    expect( page ).to have_content "Test message"
    expect( page ).to have_content "2 users"

    expect( Phone.count ).to be > 2
    expect( SMS.outgoing.count ).to eq 2
    expect( SMS.outgoing.pluck(:text).uniq ).to eq ["Test message"]

    user_numbers = User.
      where(country: @countries).includes(:phones).
      map { |u| u.primary_phone.number }
    expect( user_numbers.sort ).to eq SMS.outgoing.pluck(:number).sort
  end

  it "validates a message", :worker do
    @countries.each do |c|
      select c.name, from: "sms_bulk_sender_country_ids"
    end
    click_button "Send"

    expect( page ).not_to have_content "Test message"
    expect( page ).to have_content "No message"

    expect( SMS.outgoing.count ).to eq 0
  end
end
