import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "arrow"]
  static values = { 
    autoOpen: Boolean,
    currentPath: String 
  }

  connect() {
    // Auto-open dropdown if current page is in team or replacements section
    const currentPath = window.location.pathname
    if (currentPath.includes('/team') || currentPath.includes('/replacements')) {
      this.open()
    }
    
    // Close dropdown when clicking outside
    this.boundCloseOnClickOutside = this.closeOnClickOutside.bind(this)
    document.addEventListener('click', this.boundCloseOnClickOutside)
  }

  disconnect() {
    document.removeEventListener('click', this.boundCloseOnClickOutside)
  }

  toggle(event) {
    event.stopPropagation()
    
    // Close all other dropdowns
    document.querySelectorAll('[data-controller="dropdown"]').forEach(dropdown => {
      if (dropdown !== this.element) {
        const controller = this.application.getControllerForElementAndIdentifier(dropdown, 'dropdown')
        if (controller) {
          controller.close()
        }
      }
    })
    
    // Toggle current dropdown
    if (this.menuTarget.classList.contains('hidden')) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.menuTarget.classList.remove('hidden')
    this.menuTarget.classList.add('active')
    if (this.hasArrowTarget) {
      this.arrowTarget.style.transform = 'rotate(180deg)'
    }
  }

  close() {
    this.menuTarget.classList.add('hidden')
    this.menuTarget.classList.remove('active')
    if (this.hasArrowTarget) {
      this.arrowTarget.style.transform = 'rotate(0deg)'
    }
  }

  closeOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  mouseEnter(event) {
    event.currentTarget.style.background = 'rgba(0, 212, 255, 0.2)'
    event.currentTarget.style.color = '#FFFFFF'
  }

  mouseLeave(event) {
    // Don't reset background if this is the active link
    if (!event.currentTarget.style.background.includes('0.1')) {
      event.currentTarget.style.background = 'transparent'
      event.currentTarget.style.color = 'rgba(255, 255, 255, 0.8)'
    }
  }
}
