import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  async checkout(event) {
    event.preventDefault()
    const form = event.target
    
    try {
      const response = await fetch(form.action, {
        method: form.method,
        headers: {
          'Accept': 'application/json',
          'X-CSRF-Token': document.querySelector("[name='csrf-token']").content
        }
      })
      
      const data = await response.json()
      
      if (data.error) {
        console.error("Checkout error:", data.error)
        return
      }
      
      // Redirect to Stripe Checkout
      window.location.href = data.checkout_url
      
    } catch (error) {
      console.error("Error during checkout:", error)
    }
  }
}
