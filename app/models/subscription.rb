class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :product
  
  validates :stripe_subscription_id, uniqueness: true, allow_nil: true
  validates :status, presence: true, inclusion: { 
    in: %w[incomplete incomplete_expired active past_due canceled unpaid trialing] 
  }
  
  scope :active, -> { where(status: 'active') }
end
