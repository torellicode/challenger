class ProductsController < ApplicationController
  def index
    @products = Product.published.order(created_at: :asc)
  end

  def show
    @product = Product.published.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to products_path, alert: 'Product not found'
  end
end
