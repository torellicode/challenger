import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mobileMenu", "openButton", "closeButton"]

  connect() {
    // Initialize menu state
    this.mobileMenuTarget.classList.add("hidden")
    this.openButtonTarget.classList.remove("hidden")
    this.closeButtonTarget.classList.add("hidden")
    
    // Listen for turbo navigation to reset menu state
    document.addEventListener('turbo:visit', this.closeMenu.bind(this))
  }

  toggleMenu() {
    if (this.mobileMenuTarget.classList.contains("hidden")) {
      this.openMenu()
    } else {
      this.closeMenu()
    }
  }

  openMenu() {
    this.mobileMenuTarget.classList.remove("hidden")
    this.openButtonTarget.classList.add("hidden")
    this.closeButtonTarget.classList.remove("hidden")
  }

  closeMenu() {
    this.mobileMenuTarget.classList.add("hidden")
    this.openButtonTarget.classList.remove("hidden")
    this.closeButtonTarget.classList.add("hidden")
  }

  disconnect() {
    // Clean up event listener
    document.removeEventListener('turbo:visit', this.closeMenu.bind(this))
  }
}
