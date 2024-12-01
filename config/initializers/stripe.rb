Rails.configuration.stripe = {
  # Test keys
  test_publishable_key: Rails.application.credentials.stripe[:test_publishable_key],
  test_secret_key: Rails.application.credentials.stripe[:test_secret_key]
}

Stripe.api_key = Rails.configuration.stripe[:test_secret_key]
