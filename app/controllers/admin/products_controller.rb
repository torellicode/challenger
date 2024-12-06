module Admin
  class ProductsController < BaseController
    before_action :set_product, only: [:edit, :update, :destroy, :publish, :unpublish, :archive, :unarchive]

    def index
      @products = Product.order(created_at: :desc)
    end

    def new
      @product = Product.new
    end

    def create
      @product = Product.new(product_params)

      if @product.save
        @product.sync_with_stripe
        redirect_to admin_products_path, notice: 'Product was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @product.update(product_params)
        redirect_to admin_products_path, notice: 'Product was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @product.archive
      redirect_to admin_products_path, notice: 'Product was successfully archived.'
    end
    
    def archive
      @product.archive
      redirect_to admin_products_path, notice: 'Product was successfully archived.'
    end
    
    def unarchive
      @product.update(archived: false)
      @product.update_stripe_product if @product.stripe_product_id.present?
      redirect_to admin_products_path, notice: 'Product was successfully restored.'
    end

    def publish
      @product.update(published: true)
      @product.update_stripe_product
      redirect_to admin_products_path, notice: 'Product was successfully published.'
    end
    
    def unpublish
      @product.update(published: false)
      @product.update_stripe_product
      redirect_to admin_products_path, notice: 'Product was successfully unpublished.'
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(
        :name, 
        :description, 
        :price_in_cents, 
        :product_type, 
        :billing_period,
        :role
      )
    end
  end
end
