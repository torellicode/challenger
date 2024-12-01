module StripeHelper
  def stripe_public_key
    Rails.configuration.stripe[:test_publishable_key]
  end
end
