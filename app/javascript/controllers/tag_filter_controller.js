import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "dropdown", "search"]

  connect() {
    this.close = this.close.bind(this)
  }

  toggle(event) {
    event.stopPropagation()
    const isHidden = this.dropdownTarget.classList.contains('hidden')

    if (isHidden) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.dropdownTarget.classList.remove('hidden')
    this.searchTarget.focus()
    // Add listener on next tick to avoid immediate close
    setTimeout(() => {
      document.addEventListener('click', this.close)
    }, 0)
  }

  close() {
    this.dropdownTarget.classList.add('hidden')
    document.removeEventListener('click', this.close)
  }

  keepOpen(event) {
    // Prevent clicks inside dropdown from closing it
    event.stopPropagation()
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

  disconnect() {
    document.removeEventListener('click', this.close)
  }
}
