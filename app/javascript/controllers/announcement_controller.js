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
    if (this.visibleValue) {
      this.popupTarget.classList.remove("hidden")
      // Optional: Add transition classes
      requestAnimationFrame(() => {
        this.popupTarget.classList.add("transform", "transition", "ease-out", "duration-100", "opacity-100", "scale-100")
        this.popupTarget.classList.remove("opacity-0", "scale-95")
      })
    } else {
      // Optional: Add transition classes
      this.popupTarget.classList.add("transform", "transition", "ease-in", "duration-75", "opacity-0", "scale-95")
      this.popupTarget.classList.remove("opacity-100", "scale-100")
      setTimeout(() => {
        this.popupTarget.classList.add("hidden")
      }, 75)
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
