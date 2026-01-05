import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "dropdown", "search"]

  toggle(event) {
    event.stopPropagation()
    this.dropdownTarget.classList.toggle('hidden')

    if (!this.dropdownTarget.classList.contains('hidden')) {
      this.searchTarget.focus()
    }
  }

  submit(event) {
    // Auto-submit form when checkbox changes
    event.target.closest('form').requestSubmit()
  }

  search() {
    const query = this.searchTarget.value
    const url = `/tags?query=${encodeURIComponent(query)}`

    fetch(url, {
      headers: { 'Accept': 'text/vnd.turbo-stream.html' }
    })
      .then(response => response.text())
      .then(html => {
        Turbo.renderStreamMessage(html)
      })
  }

  // Close dropdown when clicking outside
  connect() {
    this.boundCloseOnClickOutside = this.closeOnClickOutside.bind(this)
    document.addEventListener('click', this.boundCloseOnClickOutside)
  }

  disconnect() {
    document.removeEventListener('click', this.boundCloseOnClickOutside)
  }

  closeOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.dropdownTarget.classList.add('hidden')
    }
  }
}
