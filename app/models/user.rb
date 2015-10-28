class User < ActiveRecord::Base
  devise :database_authenticatable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  default_scope { where(active: true) }

  enum role: [ :pcv, :pcmo, :admin ]
  def self.role_names
    { "PCV" => "pcv", "PCMO" => "pcmo", "Admin" => "admin" }
  end
  def role= r
    r = r.downcase if r.respond_to?(:downcase)
    super r
  end

  belongs_to :country

  paginates_per 10

  has_many :requests
  has_many :orders
  has_many :responses
  has_many :receipt_reminders

  has_many :phones, dependent: :destroy
  has_many :messages, class_name: "SMS"
  accepts_nested_attributes_for :phones, allow_destroy: true

  validates_presence_of :country, :location, :first_name, :last_name, :role
  validates :pcv_id, presence: true, uniqueness: true, if: :pcv?
  validates :time_zone, inclusion: {in: ActiveSupport::TimeZone.all.map(&:name) }

  def self.due_cutoff
    now    = Time.now
    oldest = now.at_beginning_of_month
    now.day < 3 ? oldest - 1.month : oldest
  end

  scope :past_due, -> { where ["waiting_since  < ?", due_cutoff] }
  scope :pending,  -> { where ["waiting_since >= ?", due_cutoff] }

  def self.find_by_pcv_id str
    where(['lower(pcv_id) = ?', str.downcase]).first
  end

  def self.find_by_phone_number number
    Phone.lookup(number).try :user
  end

  def primary_phone
    @_primary_phone ||= phones.first
  end

  def name
    "#{first_name} #{last_name}".strip
  end

  def textable?
    primary_phone.present?
  end

  def send_text message
    twilio = country.twilio_account
    to     = primary_phone.try :number
    return unless to
    return if spammy? to, message
    twilio.send_text to, message
  end

  def spammy? number, text
    last = messages.newest
    last && last.text == text && last.number == number && last.outgoing? && last.created_at >= 2.days.ago
  end

  def available_supplies
    country.supplies
  end

  def sms_contact_number
    n = country.twilio_account.number.to_s
    "#{n[0..-11]} (#{n[-10..-8]}) #{n[-7..-5]}-#{n[-4..-1]}"
  end

  def welcome_video
    if pcv?
      Video::PCV_WELCOME
    else
      Video::PCMO_WELCOME
    end
  end

  def record_welcome!
    self.update!(welcome_video_shown_at: Time.now)
  end

  def welcome_video_seen?
    !self.welcome_video_shown_at.nil?
  end

  def make_sms_request body
    raise unless Rails.env.development? || Rails.env.test?
    account = country.twilio_account
    SMSDispatcher.new(
      account_sid: account.sid,
      to:          account.number,
      from:        primary_phone.number,
      body:        body
    ).record_and_respond
  end

  def ensure_secret_key!
    unless secret_key.present?
      update! secret_key: ApiAuth.generate_secret_key
    end
  end
end
