class Order < ApplicationRecord
  belongs_to :user
  belongs_to :product
  
  validates :stripe_payment_intent, uniqueness: true, allow_nil: true
  validates :status, presence: true, inclusion: { in: %w[pending paid failed] }
  
  scope :paid, -> { where(status: 'paid') }
end
