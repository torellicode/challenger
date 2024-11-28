import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "openIcon", "closeIcon"]

  connect() {
    // Initialize menu as hidden
    this.menuTarget.classList.add("hidden")
    
    // Add click outside listener
    document.addEventListener("click", this.handleClickOutside.bind(this))
    // Close menu on page navigation
    document.addEventListener("turbo:visit", this.close.bind(this))
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside.bind(this))
    document.removeEventListener("turbo:visit", this.close.bind(this))
  }

  toggle(event) {
    event.stopPropagation()
    if (this.menuTarget.classList.contains("hidden")) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.menuTarget.classList.remove("hidden")
    this.openIconTarget.classList.add("hidden")
    this.closeIconTarget.classList.remove("hidden")
  }

  close() {
    this.menuTarget.classList.add("hidden")
    this.openIconTarget.classList.remove("hidden")
    this.closeIconTarget.classList.add("hidden")
  }

  handleClickOutside = (event) => {
    if (!this.element.contains(event.target) && !this.menuTarget.classList.contains("hidden")) {
      this.close()
    }
  }
}
