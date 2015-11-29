class RosterUpload < ActiveRecord::Base
  belongs_to :uploader, class_name: "User"
  belongs_to :country

  validates_presence_of :uploader, :country, :body

  def roster
    @_roster ||= Roster.from_csv(body, country: country)
  end
end