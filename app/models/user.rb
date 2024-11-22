class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :announcements, dependent: :destroy
  has_many :announcement_reads, dependent: :destroy
  has_many :read_announcements, through: :announcement_reads, source: :announcement

  # User roles
  enum role: {
    standard: 0,
    basic: 1,
    pro: 2,
    admin: 3
  }

  # Validations
  validates :username, presence: true, uniqueness: true

  # Callbacks
  after_initialize :set_default_role, if: :new_record?
  before_save :titleize_username

  # Methods
  def unread_announcements
    Announcement.published.where.not(id: announcement_reads.select(:announcement_id))
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
