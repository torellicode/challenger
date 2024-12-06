class Product < ApplicationRecord
  # Validations
  validates :name, presence: true
  validates :description, presence: true
  validates :price_in_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stripe_product_id, uniqueness: true, allow_nil: true
  validates :stripe_price_id, uniqueness: true, allow_nil: true
  validates :product_type, presence: true, inclusion: { in: %w[one_time subscription] }
  validates :billing_period, presence: true, if: :subscription?
  validates :role, presence: true, inclusion: { in: %w[basic pro] }

  # Attributes
  attribute :role, :string, default: 'basic'

  # Callbacks
  after_create :sync_with_stripe
  after_update :update_stripe_product, if: :product_details_changed?
  before_destroy :cleanup_stripe_product
  before_validation :ensure_role_is_set

  # Scopes
  scope :active, -> { where(archived: false) }
  scope :archived, -> { where(archived: true) }
  scope :published, -> { active.where(published: true) }

  # Methods
  def subscription?
    product_type == 'subscription'
  end

  def self.available_roles
    [
      ['Basic', 'basic'],
      ['Pro', 'pro']
    ]
  end

  def sync_with_stripe
    # Create or update Stripe product
    stripe_product = if stripe_product_id.present?
      Stripe::Product.update(
        stripe_product_id,
        {
          name: name,
          description: description,
          active: published
        }
      )
    else
      Stripe::Product.create(
        {
          name: name,
          description: description,
          active: published
        }
      )
    end
  
    # Create new price
    stripe_price = if subscription?
      Stripe::Price.create(
        {
          product: stripe_product.id,
          unit_amount: price_in_cents,
          currency: 'usd',
          recurring: {
            interval: billing_period # 'month' or 'year'
          }
        }
      )
    else
      Stripe::Price.create(
        {
          product: stripe_product.id,
          unit_amount: price_in_cents,
          currency: 'usd'
        }
      )
    end
  
  # Update local record with Stripe IDs
  update_columns(
    stripe_product_id: stripe_product.id,
    stripe_price_id: stripe_price.id
  )
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe Error: #{e.message}"
    errors.add(:base, "Stripe Error: #{e.message}")
    false
  end

  def update_stripe_product
    return unless stripe_product_id.present?

    Stripe::Product.update(
      stripe_product_id,
      {
        name: name,
        description: description,
        active: published
      }
    )

    if price_in_cents_previously_changed? || billing_period_previously_changed?
      # Deactivate the old price
      Stripe::Price.update(stripe_price_id, { active: false }) if stripe_price_id.present?

      # Create new price
      new_price = if subscription?
        Stripe::Price.create(
          product: stripe_product_id,
          unit_amount: price_in_cents,
          currency: 'usd',
          recurring: {
            interval: billing_period
          },
          active: true
        )
      else
        Stripe::Price.create(
          product: stripe_product_id,
          unit_amount: price_in_cents,
          currency: 'usd',
          active: true
        )
      end
      
      update_column(:stripe_price_id, new_price.id)
    end
  end

  def archive
    return true if archived?
  
    begin
      # Archive all associated prices in Stripe
      if stripe_product_id.present?
        prices = Stripe::Price.list({ product: stripe_product_id })
        prices.data.each do |price|
          Stripe::Price.update(price.id, { active: false })
        end
  
        # Archive the Stripe product
        Stripe::Product.update(stripe_product_id, { active: false })
      end
  
      # Archive in our database
      update(archived: true, published: false)
      true
    rescue Stripe::InvalidRequestError => e
      if e.message.include?('No such product')
        update(archived: true, published: false)
        true
      else
        Rails.logger.error "Stripe Error: #{e.message}"
        raise e
      end
    end
  end

  def price_in_dollars
    (price_in_cents / 100.0).round(2)
  end

  private

  def product_details_changed?
    saved_changes.any? { |attr, _| ['name', 'description', 'price_in_cents', 'published'].include?(attr) }
  end

  def cleanup_stripe_product
    return unless stripe_product_id.present?
  
    begin
      # First archive all associated prices
      prices = Stripe::Price.list({ product: stripe_product_id })
      prices.data.each do |price|
        Stripe::Price.update(price.id, { active: false })
      end
  
      # Archive the product
      Stripe::Product.update(stripe_product_id, { active: false })
  
      # Now that everything is archived, try to delete
      begin
        Stripe::Product.delete(stripe_product_id)
        Rails.logger.info "Successfully deleted Stripe product: #{stripe_product_id}"
      rescue Stripe::InvalidRequestError => e
        # If we can't delete, that's okay - at least it's archived
        Rails.logger.info "Product archived but could not be deleted: #{e.message}"
      end
  
      true
    rescue Stripe::InvalidRequestError => e
      if e.message.include?('No such product')
        # Product already gone from Stripe, that's fine
        true
      else
        Rails.logger.error "Stripe Error: #{e.message}"
        raise e
      end
    end
  end

  def ensure_role_is_set
    self.role ||= 'basic'
  end
end
