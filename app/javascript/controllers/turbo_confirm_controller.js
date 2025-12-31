import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "message", "confirmButton", "cancelButton"]

  connect() {
    // Set custom confirmation method for Turbo (uses global Turbo object)
    if (window.Turbo) {
      window.Turbo.setConfirmMethod((message, element) => {
        return this.confirm(message)
      })
    }
  }

  confirm(message) {
    return new Promise((resolve) => {
      // Store the resolve function to call later
      this.resolvePromise = resolve

      // Set the message
      this.messageTarget.textContent = message

      // Show the modal
      this.showModal()

      // Set up one-time event listeners for this confirmation
      this.confirmHandler = () => {
        this.hideModal()
        resolve(true)
      }

      this.cancelHandler = () => {
        this.hideModal()
        resolve(false)
      }

      this.confirmButtonTarget.addEventListener("click", this.confirmHandler, { once: true })
      this.cancelButtonTarget.addEventListener("click", this.cancelHandler, { once: true })
    })
  }

  showModal() {
    this.modalTarget.classList.remove("hidden")
    // Focus the cancel button for accessibility
    this.cancelButtonTarget.focus()
  }

  hideModal() {
    this.modalTarget.classList.add("hidden")
  }

  // Handle Escape key to cancel
  handleKeydown(event) {
    if (event.key === "Escape" && this.cancelHandler) {
      this.cancelHandler()
    }
  }

  disconnect() {
    // Clean up event listeners if needed
    if (this.confirmHandler) {
      this.confirmButtonTarget.removeEventListener("click", this.confirmHandler)
    }
    if (this.cancelHandler) {
      this.cancelButtonTarget.removeEventListener("click", this.cancelHandler)
    }
  }
}
