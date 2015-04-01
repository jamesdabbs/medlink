class CountriesController < ApplicationController
  skip_before_filter :authenticate_user!, only: :index

  def index
    @countries = if params[:letter] == "a"
      Country.where("name LIKE ?", "a%")
    else
      Country.all
    end
  end
end
