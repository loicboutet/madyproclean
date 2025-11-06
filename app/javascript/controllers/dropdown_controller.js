import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.isOpen = false
  }

  toggle(event) {
    event.stopPropagation()
    this.isOpen = !this.isOpen
    
    if (this.isOpen) {
      this.menuTarget.classList.remove("hidden")
      this.menuTarget.classList.add("active")
      // Add click listener to document to close on outside click
      document.addEventListener("click", this.closeOnClickOutside.bind(this))
    } else {
      this.hide()
    }
  }

  hide() {
    this.isOpen = false
    this.menuTarget.classList.add("hidden")
    this.menuTarget.classList.remove("active")
    document.removeEventListener("click", this.closeOnClickOutside.bind(this))
  }

  closeOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hide()
    }
  }

  disconnect() {
    // Clean up event listener when controller is disconnected
    document.removeEventListener("click", this.closeOnClickOutside.bind(this))
  }
}
