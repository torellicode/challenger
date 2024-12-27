module StripeTestHelper
  def stub_stripe_product_creation
    stripe_product = OpenStruct.new(id: 'prod_test123')
    stripe_price = OpenStruct.new(id: 'price_test123')

    Stripe::Product.stub :create, stripe_product do
      Stripe::Price.stub :create, stripe_price do
        yield if block_given?
      end
    end
  end

  def assert_stripe_product_fields(product)
    assert_equal 'prod_test123', product.stripe_product_id
    assert_equal 'price_test123', product.stripe_price_id
  end
end
