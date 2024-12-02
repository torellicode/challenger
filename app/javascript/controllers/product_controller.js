import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["billingPeriod"]

  connect() {
    // Set initial visibility based on selected value
    this.toggleBillingPeriod({ target: this.element.querySelector('[name*="product_type"]') })
  }

  toggleBillingPeriod(event) {
    const isSubscription = event.target.value === 'subscription'
    this.billingPeriodTarget.style.display = isSubscription ? 'block' : 'none'
  }
}
