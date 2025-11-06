import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sidebar"
export default class extends Controller {
  static targets = ["sidebar", "overlay"]

  connect() {
    this.isOpen = false
  }

  toggle(event) {
    event.preventDefault()
    this.isOpen = !this.isOpen
    
    if (this.isOpen) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.isOpen = true
    this.sidebarTarget.classList.add("open")
    this.overlayTarget.classList.add("active")
    // Prevent body scroll when sidebar is open on mobile
    document.body.style.overflow = "hidden"
  }

  close() {
    this.isOpen = false
    this.sidebarTarget.classList.remove("open")
    this.overlayTarget.classList.remove("active")
    // Restore body scroll
    document.body.style.overflow = ""
  }

  closeOnOverlay(event) {
    // Only close if clicking directly on the overlay, not its children
    if (event.target === this.overlayTarget) {
      this.close()
    }
  }

  disconnect() {
    // Clean up when controller is removed
    document.body.style.overflow = ""
  }
}
