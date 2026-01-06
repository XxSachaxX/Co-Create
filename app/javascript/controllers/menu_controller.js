import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "burger"]

  connect() {
    this.close = this.close.bind(this)
  }

  toggle(event) {
    event.stopPropagation()
    const isHidden = this.overlayTarget.classList.contains('hidden')

    if (isHidden) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    // Show dropdown
    this.overlayTarget.classList.remove('hidden')

    // Update burger icon aria-expanded
    this.burgerTarget.setAttribute('aria-expanded', 'true')

    // Add click-outside listener on next tick
    setTimeout(() => {
      document.addEventListener('click', this.close)
    }, 0)
  }

  close() {
    // Hide dropdown
    this.overlayTarget.classList.add('hidden')

    // Update burger icon aria-expanded
    this.burgerTarget.setAttribute('aria-expanded', 'false')

    // Remove click-outside listener
    document.removeEventListener('click', this.close)
  }

  keepOpen(event) {
    // Prevent clicks inside menu from closing it
    event.stopPropagation()
  }

  handleKeydown(event) {
    // Close menu on ESC key
    if (event.key === 'Escape') {
      this.close()
    }
  }

  disconnect() {
    document.removeEventListener('click', this.close)
  }
}
