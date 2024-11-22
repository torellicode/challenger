import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "popup", "badge"]
  static values = {
    count: Number,
    visible: Boolean
  }

  connect() {
    // Initialize the popup as hidden
    this.popupTarget.classList.add("hidden")
    this.visibleValue = false
    
    // Listen for turbo:stream events
    document.addEventListener("turbo:stream-connect", this.updateCount.bind(this))
  }

  updateCount() {
    // Get the current unread count from the badge
    const badge = this.badgeTarget
    if (badge) {
      const count = parseInt(badge.textContent)
      this.countValue = count
    }
  }

  toggle() {
    this.visibleValue = !this.visibleValue
    if (this.visibleValue) {
      this.popupTarget.classList.remove("hidden")
    } else {
      this.popupTarget.classList.add("hidden")
    }
  }

  // Close popup when clicking outside
  clickOutside(event) {
    if (!this.element.contains(event.target) && this.visibleValue) {
      this.visibleValue = false
      this.popupTarget.classList.add("hidden")
    }
  }

  // Bind click outside event
  visibleValueChanged() {
    if (this.visibleValue) {
      document.addEventListener("click", this.clickOutside.bind(this))
    } else {
      document.removeEventListener("click", this.clickOutside.bind(this))
    }
  }
}
