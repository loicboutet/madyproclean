import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ["container", "backdrop"]

  connect() {
    this.isOpen = false
  }

  open(event) {
    event.preventDefault()
    this.isOpen = true
    this.containerTarget.classList.remove("hidden")
    this.containerTarget.classList.add("active")
    
    // Prevent body scroll when modal is open
    document.body.style.overflow = "hidden"
    
    // Add ESC key listener
    this.escapeHandler = this.handleEscape.bind(this)
    document.addEventListener("keydown", this.escapeHandler)
  }

  close(event) {
    if (event) {
      event.preventDefault()
    }
    this.isOpen = false
    this.containerTarget.classList.remove("active")
    this.containerTarget.classList.add("hidden")
    
    // Re-enable body scroll
    document.body.style.overflow = ""
    
    // Remove ESC key listener
    document.removeEventListener("keydown", this.escapeHandler)
  }

  closeOnBackdrop(event) {
    // Only close if clicking directly on the backdrop, not on child elements
    if (event.target === this.backdropTarget) {
      this.close(event)
    }
  }

  handleEscape(event) {
    if (event.key === "Escape" && this.isOpen) {
      this.close()
    }
  }

  disconnect() {
    // Clean up: re-enable body scroll and remove listener
    document.body.style.overflow = ""
    if (this.escapeHandler) {
      document.removeEventListener("keydown", this.escapeHandler)
    }
  }
}
