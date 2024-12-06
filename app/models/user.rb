class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :announcements, dependent: :destroy
  has_many :announcement_reads, dependent: :destroy
  has_many :read_announcements, through: :announcement_reads, source: :announcement
  has_many :subscriptions
  has_many :orders
  has_one :active_subscription, -> { active }, class_name: 'Subscription'

  # User roles
  enum role: {
    standard: 'standard',
    basic: 'basic',
    pro: 'pro',
    admin: 'admin'
  }

  # Attributes
  attribute :role, :string, default: 'standard'

  # Validations
  validates :username, presence: true, uniqueness: true
  # validates :stripe_payment_intent, uniqueness: true, allow_nil: true
  # validates :status, presence: true, inclusion: { in: %w[pending paid failed] }

  # Callbacks
  after_initialize :set_default_role, if: :new_record?
  before_save :titleize_username

  # Scopes
  scope :paid, -> { where(status: 'paid') }

  # Methods
  def unread_announcements
    Announcement.published.where.not(id: announcement_reads.select(:announcement_id))
  end

  def unread_announcements_count
    unread_announcements.count
  end

  def subscribed?
    active_subscription.present?
  end

  def admin?
    role == 'admin'
  end

  private

  # Private methods
  def set_default_role
    self.role ||= :standard
  end

  def titleize_username
    self.username = self.username.titleize
  end
end
