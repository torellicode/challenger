class StripeService
  def self.create_payment_intent(amount_in_cents, currency = 'usd')
    Stripe::PaymentIntent.create(
      amount: amount_in_cents,
      currency: currency
    )
  end

  def self.create_customer(email, payment_method_id)
    Stripe::Customer.create(
      email: email,
      payment_method: payment_method_id
    )
  end
end
