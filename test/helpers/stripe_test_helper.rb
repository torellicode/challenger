module StripeTestHelper
  def stub_stripe_product_creation
    stripe_product = OpenStruct.new(id: 'prod_test123')
    stripe_price = OpenStruct.new(id: 'price_test123')

    # Stub ALL Stripe API calls that might occur
    Stripe::Product.stubs(:create).returns(stripe_product)
    Stripe::Price.stubs(:create).returns(stripe_price)
    Stripe::Product.stubs(:update).returns(stripe_product)
    
    # Stub the list and delete methods too
    Stripe::Price.stubs(:list).returns(OpenStruct.new(data: []))
    Stripe::Product.stubs(:delete).returns(true)
    Stripe::Price.stubs(:update).returns(true)
  end

  def assert_stripe_product_fields(product)
    assert_equal 'prod_test123', product.stripe_product_id
    assert_equal 'price_test123', product.stripe_price_id
  end
end
