require "test_helper"

class Admin::ProductsManagementTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin_user)
    sign_in @admin
  end

  test "admin can create a new one timeproduct" do
    get new_admin_product_path
    assert_response :success

    assert_difference('Product.count') do
      post admin_products_path, params: {
        product: {
          name: 'Test Product',
          description: 'A test product description',
          price_in_cents: 2000,
          product_type: 'one_time',
          role: 'basic'
        }
      }
    end

    assert_redirected_to admin_products_path
    assert_equal 'Product was successfully created.', flash[:notice]
    
    # Verify the product was created with correct attributes
    product = Product.last
    assert_equal 'Test Product', product.name
    assert_equal 'A test product description', product.description
    assert_equal 2000, product.price_in_cents
    assert_equal 'one_time', product.product_type
    assert_equal 'basic', product.role
  end

  test "non-admin cannot access product creation" do
    sign_out @admin
    regular_user = users(:regular_user)
    sign_in regular_user

    get new_admin_product_path
    assert_redirected_to root_path
    assert_equal "You are not authorized to access this area.", flash[:alert]

    post admin_products_path, params: {
      product: {
        name: 'Test Product',
        description: 'A test product description',
        price_in_cents: 2000
      }
    }
    assert_redirected_to root_path
  end
end
