import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "openIcon", "closeIcon"]

  connect() {
    this.menuTarget.classList.add("hidden")
    document.addEventListener("click", this.handleClickOutside.bind(this))
    document.addEventListener("turbo:visit", this.close.bind(this))
    document.addEventListener("dropdown:opened", this.close.bind(this))
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside.bind(this))
    document.removeEventListener("turbo:visit", this.close.bind(this))
    document.removeEventListener("dropdown:opened", this.close.bind(this))
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
    document.dispatchEvent(new CustomEvent('hamburger:opened'))
    this.menuTarget.classList.remove("hidden")
    this.openIconTarget.classList.add("hidden")
    this.closeIconTarget.classList.remove("hidden")
    // Show overlay
    const overlay = document.querySelector('[data-nav-target="overlay"]')
    if (overlay) overlay.classList.remove("hidden")
  }

  close() {
    this.menuTarget.classList.add("hidden")
    this.openIconTarget.classList.remove("hidden")
    this.closeIconTarget.classList.add("hidden")
    // Hide overlay
    const overlay = document.querySelector('[data-nav-target="overlay"]')
    if (overlay) overlay.classList.add("hidden")
  }

  handleClickOutside = (event) => {
    if (!this.element.contains(event.target) && !this.menuTarget.classList.contains("hidden")) {
      this.close()
    }
  }
}
