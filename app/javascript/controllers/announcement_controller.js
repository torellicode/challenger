import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "popup"]
  static values = {
    count: Number,
    visible: Boolean
  }

  connect() {
    // Initialize the popup as hidden
    this.popupTarget.classList.add("hidden")
    this.visibleValue = false
  }

  toggle() {
    this.visibleValue = !this.visibleValue
    this.popupTarget.classList.toggle("hidden")
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
