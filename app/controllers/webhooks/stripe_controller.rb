module Webhooks
  class StripeController < ActionController::Base
    protect_from_forgery with: :null_session
    
    def create
      payload = request.body.read
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      
      begin
        event = Stripe::Webhook.construct_event(
          payload, sig_header, Rails.application.credentials.stripe[:webhook_secret]
        )
        Rails.logger.info "✅ Successfully verified webhook signature"
      rescue JSON::ParserError => e
        Rails.logger.error "❌ Invalid payload"
        return head :bad_request
      rescue Stripe::SignatureVerificationError => e
        Rails.logger.error "❌ Invalid signature"
        return head :bad_request
      end
    
      case event.type
      when 'checkout.session.completed'
        handle_checkout_session_completed(event)
      when 'customer.subscription.updated'
        handle_subscription_updated(event)
      when 'customer.subscription.deleted'
        handle_subscription_deleted(event)
      end
    
      head :ok
    end

    private

    attr_reader :event

    def handle_checkout_session_completed(event)
      session = event.data.object
      
      return unless session.metadata&.product_id
      
      user = User.find_by(id: session.client_reference_id)
      product = Product.find_by(id: session.metadata.product_id)
      
      Rails.logger.info "🔍 Checkout completed - User: #{user&.id}, Product: #{product&.id}, Product role: #{product&.role}"
      
      return unless user && product
      return if user.admin?
      
      # Create subscription record
      subscription = Subscription.create!(
        user: user,
        product: product,
        stripe_subscription_id: session.subscription,
        status: 'active'
      )
      
      # Update user's stripe customer ID and role
      previous_role = user.role
      user.update!(
        stripe_customer_id: session.customer,
        role: product.role
      )
      
      Rails.logger.info "✅ User #{user.id} role updated from #{previous_role} to #{product.role}"
    end
    
    def handle_subscription_updated(event)
      subscription_data = event.data.object
      subscription = Subscription.find_by(stripe_subscription_id: subscription_data.id)
      
      return unless subscription
      return if subscription.user.admin?  # Don't modify admin roles
    
      subscription.update!(status: subscription_data.status)
      
      if subscription_data.status == 'active'
        # Update user role to product's role when subscription is active
        subscription.user.update!(role: subscription.product.role)
        Rails.logger.info "✅ Updated user #{subscription.user.id} role to: #{subscription.product.role}"
      elsif ['canceled', 'incomplete_expired', 'unpaid'].include?(subscription_data.status)
        # Reset user role to standard when subscription is inactive
        subscription.user.update!(role: 'standard')
        Rails.logger.info "⏮️ Reset user #{subscription.user.id} role to: standard"
      end
    end
    
    def handle_subscription_deleted(event)
      subscription_data = event.data.object
      subscription = Subscription.find_by(stripe_subscription_id: subscription_data.id)
      
      return unless subscription
      return if subscription.user.admin?  # Don't modify admin roles
    
      subscription.update!(status: 'canceled')
      subscription.user.update!(role: 'standard')
      Rails.logger.info "❌ Canceled subscription and reset role for user #{subscription.user.id}"
    end
  end 
end
