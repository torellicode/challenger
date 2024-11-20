class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: {
    standard: 0,
    basic: 1,
    pro: 2,
    admin: 3
  }

  validates :username, presence: true, uniqueness: true

  after_initialize :set_default_role, if: :new_record?
  before_save :titleize_username
  
  private

  def set_default_role
    self.role ||= :standard
  end

  def titleize_username
    self.username = self.username.titleize
  end
end
