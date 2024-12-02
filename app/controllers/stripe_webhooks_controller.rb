class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = Rails.application.credentials.stripe[:webhook_secret]

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      return head :bad_request
    rescue Stripe::SignatureVerificationError => e
      return head :bad_request
    end

    # Handle the event
    case event.type
    when 'payment_intent.succeeded'
      payment_intent = event.data.object
      # Handle successful payment
      case event.type
      when 'payment_intent.succeeded'
        payment_intent = event.data.object
        
        # Log the successful payment
        Rails.logger.info "Payment succeeded: #{payment_intent.id}"
  
        # Find or update the associated order/subscription/user
        # Example:
        # order = Order.find_by(payment_intent_id: payment_intent.id)
        # order.update(status: 'paid') if order
  
        # You might want to:
        # 1. Update user subscription status
        # user = User.find_by(stripe_customer_id: payment_intent.customer)
        # user.update(role: :pro) if user
  
        # 2. Send confirmation email
        # UserMailer.payment_confirmation(user).deliver_later if user
  
        # 3. Create a payment record
        # Payment.create!(
        #   amount: payment_intent.amount,
        #   stripe_id: payment_intent.id,
        #   user: user
        # )
      when 'payment_intent.payment_failed'
        payment_intent = event.data.object
        Rails.logger.error "Payment failed: #{payment_intent.id}"
        
        # Handle failed payment
        # Example:
        # order = Order.find_by(payment_intent_id: payment_intent.id)
        # order.update(status: 'failed') if order
      end
    end

    head :ok
  end
end
