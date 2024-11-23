import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.menuTarget.classList.add("hidden")
    // Add click outside listener
    document.addEventListener("click", this.handleClickOutside.bind(this))
  }

  disconnect() {
    // Clean up listener when controller disconnects
    document.removeEventListener("click", this.handleClickOutside.bind(this))
  }

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.classList.toggle("hidden")
  }

  handleClickOutside = (event) => {
    if (!this.element.contains(event.target) && !this.menuTarget.classList.contains("hidden")) {
      this.menuTarget.classList.add("hidden")
    }
  }
}
