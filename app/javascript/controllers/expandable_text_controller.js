import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["preview", "full", "buttonText", "icon"]

  connect() {
    this.expanded = false
  }

  toggle() {
    this.expanded = !this.expanded

    if (this.expanded) {
      // Show full text
      this.previewTarget.style.display = "none"
      this.fullTarget.style.display = "block"
      this.buttonTextTarget.textContent = "Show less"
      this.iconTarget.style.transform = "rotate(180deg)"
    } else {
      // Show preview
      this.previewTarget.style.display = "-webkit-box"
      this.fullTarget.style.display = "none"
      this.buttonTextTarget.textContent = "Show more"
      this.iconTarget.style.transform = "rotate(0deg)"
    }
  }
}
