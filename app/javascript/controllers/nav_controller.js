import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mobileMenu", "openButton", "closeButton", "dropdown", "overlay"]
  static values = {
    activeDropdown: String
  }

  connect() {
    this.closeAll()
    document.addEventListener('click', this.handleClickOutside.bind(this))
    document.addEventListener('turbo:visit', this.closeAll.bind(this))
    this.overlayTarget.addEventListener('click', this.closeAll.bind(this))
  }

  disconnect() {
    document.removeEventListener('click', this.handleClickOutside.bind(this))
    document.removeEventListener('turbo:visit', this.closeAll.bind(this))
    this.overlayTarget.removeEventListener('click', this.closeAll.bind(this))
  }

  toggleDropdown(event) {
    const dropdownId = event.currentTarget.dataset.dropdownId
    
    if (this.activeDropdownValue === dropdownId) {
      this.closeAll()
    } else {
      this.closeAll()
      this.openDropdown(dropdownId)
    }
    
    event.stopPropagation()
  }

  toggleMenu(event) {
    if (this.activeDropdownValue === 'mobileMenu') {
      this.closeAll()
    } else {
      this.closeAll()
      this.openMobileMenu()
    }
    event.stopPropagation()
  }

  openDropdown(dropdownId) {
    this.activeDropdownValue = dropdownId
    const dropdown = this.dropdownTargets.find(
      el => el.dataset.dropdownId === dropdownId
    )
    if (dropdown) {
      dropdown.classList.remove('hidden')
    }
  }

  openMobileMenu() {
    this.activeDropdownValue = 'mobileMenu'
    this.mobileMenuTarget.classList.remove('hidden')
    this.overlayTarget.classList.remove('hidden')
    this.openButtonTarget.classList.add('hidden')
    this.closeButtonTarget.classList.remove('hidden')
  }

  closeAll() {
    this.activeDropdownValue = ''
    
    // Close all dropdowns
    this.dropdownTargets.forEach(dropdown => {
      dropdown.classList.add('hidden')
    })
    
    // Close mobile menu and overlay
    this.mobileMenuTarget.classList.add('hidden')
    this.overlayTarget.classList.add('hidden')
    this.openButtonTarget.classList.remove('hidden')
    this.closeButtonTarget.classList.add('hidden')
  }

  handleClickOutside(event) {
    const isClickInNav = this.element.contains(event.target)
    const isClickInMobileMenu = this.mobileMenuTarget.contains(event.target)
    const isClickOnOverlay = this.overlayTarget.contains(event.target)
    
    if (!isClickInNav && !isClickInMobileMenu || isClickOnOverlay) {
      this.closeAll()
    }
  }

  // New method specifically for handling navigation clicks
  handleNavClick(event) {
    // Don't prevent default behavior - allow the link to work
    this.closeAll()
  }
}
