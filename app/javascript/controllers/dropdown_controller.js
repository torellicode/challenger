import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.menuTarget.classList.add("hidden")
  }

  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }

  // Close when clicking outside
  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }
}
