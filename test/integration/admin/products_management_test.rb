require "test_helper"
require "helpers/stripe_test_helper"

class Admin::ProductsManagementTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include StripeTestHelper

  # Setup
  setup do
    @admin_user = users(:admin_user)
    @standard_user = users(:standard_user)
    @subscription_product = products(:subscription_product)
    @one_time_product = products(:one_time_product)

    @valid_one_time_product_params = {
      name: "Test Product",
      price_in_cents: 1000,
      billing_period: nil,
      product_type: "one_time",
      role: "basic",
      description: "This is a test product"
    }

    @valid_subscription_product_params = {
      name: "Test Product",
      price_in_cents: 1000,
      billing_period: "month",
      product_type: "subscription",
      role: "basic",
      description: "This is a test product"
    }
  end

  # Admin user tests  
  describe "as admin" do
    setup do 
      sign_in @admin_user
    end

    test "admin can GET products management page" do
      get admin_products_path
      assert_response :success
    end
  
    test "admin can POST products management page" do
      assert_difference "Product.count", 1 do
        post admin_products_path, params: { product: @valid_one_time_product_params }
      end
      assert_response :redirect
      assert_redirected_to admin_products_path
    end
  
    test "admin can PATCH products management page" do
      patch admin_product_path(@one_time_product), params: { product: { name: "Updated Product" } }
      assert_response :redirect
      assert_redirected_to admin_products_path
      assert_equal "Product was successfully updated.", flash[:notice]
    end
  
    test "admin can DELETE toarchive a product" do
      assert_changes -> { @one_time_product.reload.archived } do
        delete admin_product_path(@one_time_product)
      end
      assert_response :redirect
      assert_redirected_to admin_products_path
    end

    test "admin can create a one time product with valid params" do
      assert_difference "Product.count", 1 do
        post admin_products_path, params: { product: @valid_one_time_product_params }
      end
      assert_response :redirect
      assert_redirected_to admin_products_path
    end
  
    test "admin can create a subscription product with valid params" do
      assert_difference "Product.count", 1 do
        post admin_products_path, params: { product: @valid_subscription_product_params }
      end
      assert_response :redirect
      assert_redirected_to admin_products_path
    end
  
    test "admin cannot create a one time product with invalid params" do
      assert_no_difference "Product.count" do
        post admin_products_path, params: { product: @valid_one_time_product_params.merge(name: nil) }
      end
      assert_response :unprocessable_entity
    end
  
    test "admin cannot create a subscription product with invalid params" do
      assert_no_difference "Product.count" do
        post admin_products_path, params: { product: @valid_subscription_product_params.merge(name: nil) }
      end
      assert_response :unprocessable_entity
    end
  
    test "product requires a name" do
      assert_no_difference "Product.count" do
        post admin_products_path, params: { product: @valid_one_time_product_params.merge(name: nil) }
      end
      assert_response :unprocessable_entity
    end 
  
    test "product requires a price" do
      assert_no_difference "Product.count" do
        post admin_products_path, params: { product: @valid_one_time_product_params.merge(price_in_cents: nil) }
      end
      assert_response :unprocessable_entity
    end
  
    test "product requires a product type" do
      assert_no_difference "Product.count" do
        post admin_products_path, params: { product: @valid_one_time_product_params.merge(product_type: nil) }
      end
      assert_response :unprocessable_entity
    end
  
    test "product requires a role" do
      assert_no_difference "Product.count" do
        post admin_products_path, params: { product: @valid_one_time_product_params.merge(role: "") }
      end
      assert_response :unprocessable_entity
    end
  
    test "product requires a description" do
      assert_no_difference "Product.count" do
        post admin_products_path, params: { product: @valid_one_time_product_params.merge(description: nil) }
      end
      assert_response :unprocessable_entity
    end
  
    test "subscription product requires a billing period" do
      assert_no_difference "Product.count" do
        post admin_products_path, params: { product: @valid_subscription_product_params.merge(billing_period: nil) }
      end
      assert_response :unprocessable_entity
    end
  
    test "one time product cannot have a billing period" do
      assert_no_difference "Product.count" do
        post admin_products_path, params: { product: @valid_one_time_product_params.merge(billing_period: "month") }
      end
      assert_response :unprocessable_entity
    end
  
    test "product price must be greater than 0" do
      assert_no_difference "Product.count" do
        post admin_products_path, params: { product: @valid_one_time_product_params.merge(price_in_cents: 0) }
      end
      assert_response :unprocessable_entity
    end
  end 

  # Standard user tests
  describe "as standard user" do
    setup do
      sign_in @standard_user
    end

    test "standard user cannot GET products management page" do
      get admin_products_path
      assert_response :redirect
      assert_redirected_to root_path
      assert_equal "You are not authorized to access this area.", flash[:alert]
    end
  
    test "standard user cannot POST products management page" do
      assert_no_difference "Product.count" do
        post admin_products_path, params: { product: @valid_one_time_product_params }
      end
      assert_response :redirect
      assert_redirected_to root_path
      assert_equal "You are not authorized to access this area.", flash[:alert]
    end
    
    test "standard user cannot PATCH products management page" do
      assert_no_changes -> { @one_time_product.reload.attributes } do
        patch admin_product_path(@one_time_product), params: { 
          product: { 
            name: "Updated Product",
            description: "New description",
            price_in_cents: 9999
          } 
        }
      end
      assert_response :redirect
      assert_redirected_to root_path
      assert_equal "You are not authorized to access this area.", flash[:alert]
    end
  
    test "standard user cannot DELETE products management page" do
      assert_no_difference "Product.count" do
        delete admin_product_path(@one_time_product)
      end
      assert_response :redirect
      assert_redirected_to root_path
      assert_equal "You are not authorized to access this area.", flash[:alert]
    end
  end
end
