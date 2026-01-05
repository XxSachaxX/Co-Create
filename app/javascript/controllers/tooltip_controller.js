import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { content: String }

  connect() {
    this.tooltip = null
  }

  show(event) {
    // Simple tooltip - can upgrade to Tippy.js later
    this.tooltip = document.createElement('div')
    this.tooltip.className = 'absolute z-50 px-3 py-2 text-sm bg-charcoal-900 text-white rounded shadow-lg whitespace-nowrap'
    this.tooltip.textContent = this.contentValue

    const rect = this.element.getBoundingClientRect()
    this.tooltip.style.top = `${rect.bottom + window.scrollY + 5}px`
    this.tooltip.style.left = `${rect.left + window.scrollX}px`

    document.body.appendChild(this.tooltip)
  }

  hide() {
    if (this.tooltip) {
      this.tooltip.remove()
      this.tooltip = null
    }
  }
}
