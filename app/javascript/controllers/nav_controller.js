import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropdown", "overlay"]
  static values = {
    activeDropdown: String
  }

  connect() {
    // Initialize all dropdowns as hidden
    this.dropdownTargets.forEach(dropdown => {
      const menu = dropdown.querySelector('[data-dropdown-target="menu"]')
      if (menu) menu.classList.add('hidden')
    })
    
    document.addEventListener('click', this.handleClickOutside.bind(this))
    document.addEventListener('turbo:visit', this.closeAll.bind(this))
    document.addEventListener('hamburger:opened', this.closeAll.bind(this))
  }

  disconnect() {
    document.removeEventListener('click', this.handleClickOutside.bind(this))
    document.removeEventListener('turbo:visit', this.closeAll.bind(this))
    document.removeEventListener('hamburger:opened', this.closeAll.bind(this))
  }

  toggleDropdown(event) {
    event.stopPropagation()
    const dropdownId = event.currentTarget.dataset.dropdownId
    const dropdown = this.dropdownTargets.find(el => el.dataset.dropdownId === dropdownId)
    const menu = dropdown.querySelector('[data-dropdown-target="menu"]')
    
    document.dispatchEvent(new CustomEvent('dropdown:opened'))
    
    if (this.activeDropdownValue === dropdownId) {
      this.closeAll()
    } else {
      this.closeAll()
      this.activeDropdownValue = dropdownId
      menu.classList.remove('hidden')
      // Only show overlay for announcements on mobile
      if (dropdownId === 'announcements' && window.innerWidth < 640) {
        this.overlayTarget.classList.remove('hidden')
      }
    }
  }

  closeAll() {
    this.activeDropdownValue = ''
    this.dropdownTargets.forEach(dropdown => {
      const menu = dropdown.querySelector('[data-dropdown-target="menu"]')
      if (menu) menu.classList.add('hidden')
    })
    this.overlayTarget.classList.add('hidden')
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target) || event.target === this.overlayTarget) {
      this.closeAll()
    }
  }
}
