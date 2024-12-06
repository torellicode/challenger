class CheckoutsController < ApplicationController
  before_action :authenticate_user!
  
  def create
    product = Product.find(params[:product_id])
    
    session = Stripe::Checkout::Session.create({
      customer_email: current_user.email,
      client_reference_id: current_user.id.to_s,
      metadata: {
        product_id: product.id.to_s
      },
      payment_method_types: ['card'],
      line_items: [{
        price: product.stripe_price_id,
        quantity: 1
      }],
      mode: product.subscription? ? 'subscription' : 'payment',
      success_url: success_checkouts_url(host: request.base_url),
      cancel_url: cancel_checkouts_url(host: request.base_url)
    })
    
    Rails.logger.info "Created checkout session: #{session.id} with metadata: #{session.metadata.inspect}"
    render json: { checkout_url: session.url }
  rescue => e
    Rails.logger.error "Checkout error: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.join("\n")  # Add stack trace for debugging
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def success
    flash[:notice] = "Successfully purchased. Thank you and enjoy!"
    redirect_to root_path
  end

  def cancel
    flash[:alert] = "Your purchase was cancelled."
    redirect_to products_path
  end
end
