import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="qr-scanner"
export default class extends Controller {
  static targets = ["modal", "reader", "status", "scanButton"]

  connect() {
    this.html5QrCode = null
    this.isScanning = false
  }

  buttonHoverIn(event) {
    event.currentTarget.style.transform = 'translateY(-2px)'
    event.currentTarget.style.boxShadow = '0 6px 16px rgba(0, 212, 255, 0.4)'
  }

  buttonHoverOut(event) {
    event.currentTarget.style.transform = 'translateY(0)'
    event.currentTarget.style.boxShadow = '0 4px 12px rgba(0, 212, 255, 0.3)'
  }

  disconnect() {
    this.stopScanning()
  }

  async openScanner() {
    this.modalTarget.style.display = 'flex'
    document.body.style.overflow = 'hidden'
    
    try {
      // Wait a bit for modal to render and library to load
      await new Promise(resolve => setTimeout(resolve, 300))
      
      // Create a div element for the reader if it doesn't exist
      if (!this.readerTarget.querySelector('#qr-reader')) {
        const readerDiv = document.createElement('div')
        readerDiv.id = 'qr-reader'
        this.readerTarget.appendChild(readerDiv)
      }
      
      // Check if Html5Qrcode is available globally (from CDN)
      if (typeof Html5Qrcode === 'undefined') {
        throw new Error('Html5Qrcode library not loaded. Please refresh the page.')
      }
      
      this.html5QrCode = new Html5Qrcode("qr-reader", {
        formatsToSupport: [0], // QR_CODE format
        verbose: false
      })
      
      const qrCodeSuccessCallback = (decodedText, decodedResult) => {
        this.handleScanSuccess(decodedText)
      }
      
      const config = {
        fps: 10,
        qrbox: { width: 250, height: 250 },
        aspectRatio: 1.0,
        disableFlip: false
      }
      
      this.statusTarget.textContent = 'Initialisation de la caméra...'
      this.statusTarget.style.background = 'rgba(0, 212, 255, 0.1)'
      this.statusTarget.style.borderColor = 'rgba(0, 212, 255, 0.3)'
      this.statusTarget.style.color = '#00D4FF'
      
      // Start scanning with back camera preference
      await this.html5QrCode.start(
        { facingMode: "environment" },
        config,
        qrCodeSuccessCallback
      )
      
      this.isScanning = true
      this.statusTarget.textContent = 'Caméra prête - Scannez le QR code'
    } catch (err) {
      console.error('Error starting QR scanner:', err)
      console.error('Error details:', err.name, err.message)
      
      let errorMessage = 'Erreur: Impossible d\'accéder à la caméra.'
      
      if (err.name === 'NotAllowedError') {
        errorMessage = 'Accès à la caméra refusé. Veuillez autoriser l\'accès à la caméra dans les paramètres du navigateur.'
      } else if (err.name === 'NotFoundError') {
        errorMessage = 'Aucune caméra détectée sur cet appareil.'
      } else if (err.name === 'NotSupportedError' || err.name === 'InsecureContextError') {
        errorMessage = 'La caméra nécessite une connexion sécurisée (HTTPS). Essayez sur localhost ou HTTPS.'
      } else if (err.name === 'NotReadableError') {
        errorMessage = 'La caméra est déjà utilisée par une autre application.'
      } else if (err.message) {
        errorMessage = `Erreur: ${err.message}`
      }
      
      this.showError(errorMessage)
    }
  }

  async closeScanner() {
    await this.stopScanning()
    this.modalTarget.style.display = 'none'
    document.body.style.overflow = ''
    
    // Clean up the reader div
    const readerDiv = this.readerTarget.querySelector('#qr-reader')
    if (readerDiv) {
      readerDiv.innerHTML = ''
    }
  }

  async stopScanning() {
    if (this.html5QrCode && this.isScanning) {
      try {
        await this.html5QrCode.stop()
        this.isScanning = false
      } catch (err) {
        console.error('Error stopping scanner:', err)
      }
    }
  }

  handleScanSuccess(decodedText) {
    this.showSuccess('QR Code détecté! Redirection...')
    
    // Stop scanning
    this.stopScanning()
    
    // Redirect to the scanned URL after a brief moment
    setTimeout(() => {
      window.location.href = decodedText
    }, 500)
  }

  showError(message) {
    this.statusTarget.textContent = message
    this.statusTarget.style.background = 'rgba(255, 107, 107, 0.1)'
    this.statusTarget.style.borderColor = 'rgba(255, 107, 107, 0.3)'
    this.statusTarget.style.color = '#ff6b6b'
  }

  showSuccess(message) {
    this.statusTarget.textContent = message
    this.statusTarget.style.background = 'rgba(74, 222, 128, 0.1)'
    this.statusTarget.style.borderColor = 'rgba(74, 222, 128, 0.3)'
    this.statusTarget.style.color = '#4ade80'
  }
}
