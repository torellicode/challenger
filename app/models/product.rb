class Product < ApplicationRecord
  # Validations
  validates :name, presence: true
  validates :description, presence: true
  validates :price_in_cents, presence: true, numericality: { greater_than: 0 }
  validates :product_type, presence: true, inclusion: { in: %w[one_time subscription] }
  validates :role, presence: true, inclusion: { in: %w[basic pro] }
  
  # Subscription-specific validations
  validates :billing_period, presence: true, if: :subscription?
  validate :billing_period_only_for_subscriptions

  # Callbacks
  after_create :create_stripe_product
  after_update :update_stripe_product, if: :should_update_stripe?
  before_destroy :archive_product

  # Scopes
  scope :active, -> { where(archived: false) }
  scope :archived, -> { where(archived: true) }
  scope :published, -> { where(published: true) }


  # Methods
  def subscription?
    product_type == 'subscription'
  end

  def price_in_dollars
    (price_in_cents / 100.0).round(2)
  end

  def self.available_roles
    [
      ['Basic', 'basic'],
      ['Pro', 'pro']
    ]
  end

  private

  def billing_period_only_for_subscriptions
    if product_type == 'one_time' && billing_period.present?
      errors.add(:billing_period, 'must be blank for one-time products')
    end
  end

  def create_stripe_product
    stripe_product = Stripe::Product.create(
      name: name,
      description: description,
      active: !archived
    )

    stripe_price = create_stripe_price(stripe_product.id)

    update_columns(
      stripe_product_id: stripe_product.id,
      stripe_price_id: stripe_price.id
    )
  rescue Stripe::StripeError => e
    errors.add(:base, "Stripe Error: #{e.message}")
    throw(:abort)
  end

  def create_stripe_price(stripe_product_id)
    price_params = {
      product: stripe_product_id,
      unit_amount: price_in_cents,
      currency: 'usd'
    }

    if subscription?
      price_params[:recurring] = { interval: billing_period }
    end

    Stripe::Price.create(price_params)
  end

  def update_stripe_product
    return true unless stripe_product_id.present?

    Stripe::Product.update(stripe_product_id, 
      name: name,
      description: description,
      active: !archived
    )
    true
  rescue Stripe::StripeError => e
    errors.add(:base, "Stripe Error: #{e.message}")
    false
  end

  def should_update_stripe?
    saved_changes.any? { |attr, _| ['name', 'description', 'archived'].include?(attr) }
  end

  def should_update_stripe?
    saved_changes.any? { |attr, _| ['name', 'description', 'archived'].include?(attr) }
  end

  def archive_product
    update(archived: true)
    update_stripe_product
  end
end
