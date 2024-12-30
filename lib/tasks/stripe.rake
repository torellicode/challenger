namespace :stripe do
  desc "Clean up test products from Stripe by archiving them"
  task cleanup_test_products: :environment do
    puts "Starting Stripe product cleanup..."
    archived_count = 0
    
    begin
      products = Stripe::Product.list(limit: 100)
      products.auto_paging_each do |product|
        next unless product.name.downcase.include?("test") || 
                    product.name.downcase.include?("basic access") ||
                    product.name.downcase.include?("pro subscription")

        puts "\nProcessing: #{product.name}"
        
        begin
          # Archive all prices for this product
          prices = Stripe::Price.list(product: product.id)
          prices.each do |price|
            puts "  Archiving price: #{price.id}"
            Stripe::Price.update(price.id, { active: false })
          end
          
          # Archive the product
          puts "  Archiving product: #{product.id}"
          Stripe::Product.update(product.id, { active: false })
          
          archived_count += 1
          puts "  Successfully archived product and its prices"
        rescue => e
          puts "  Error processing product #{product.name}: #{e.message}"
        end
      end
      
      puts "\nCleanup complete!"
      puts "Archived #{archived_count} products"
      
    rescue => e
      puts "Error during cleanup: #{e.message}"
    end
  end

  desc "List all Stripe products and their prices"
  task list_products: :environment do
    puts "Listing all Stripe products and prices..."
    
    products = Stripe::Product.list(limit: 100, active: true)
    products.auto_paging_each do |product|
      puts "\nProduct: #{product.name} (#{product.id})"
      puts "Active: #{product.active}"
      
      prices = Stripe::Price.list(product: product.id)
      prices.each do |price|
        puts "  Price: #{price.id}"
        puts "    Amount: #{price.unit_amount / 100.0} #{price.currency.upcase}"
        puts "    Active: #{price.active}"
        puts "    Type: #{price.type}"
        if price.type == 'recurring'
          puts "    Interval: #{price.recurring.interval}"
        end
      end
    end
  end
end
