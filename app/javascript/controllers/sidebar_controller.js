import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "overlay"]

  connect() {
    // Initialize menu state based on screen size
    this.updateMenuState()
    
    // Listen for screen size changes
    window.addEventListener('resize', this.updateMenuState.bind(this))
  }

  disconnect() {
    window.removeEventListener('resize', this.updateMenuState.bind(this))
  }

  toggle() {
    if (this.menuTarget.classList.contains('-translate-x-full')) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.menuTarget.classList.remove('-translate-x-full')
    this.overlayTarget.classList.remove('hidden')
  }

  close() {
    this.menuTarget.classList.add('-translate-x-full')
    this.overlayTarget.classList.add('hidden')
  }

  updateMenuState() {
    if (window.innerWidth >= 640) { // sm breakpoint
      this.menuTarget.classList.remove('-translate-x-full')
      this.overlayTarget.classList.add('hidden')
    } else {
      this.menuTarget.classList.add('-translate-x-full')
    }
  }
}
