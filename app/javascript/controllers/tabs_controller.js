import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = {
    defaultTab: { type: String, default: "details" }
  }

  connect() {
    this.showTab(this.defaultTabValue)
  }

  switch(event) {
    event.preventDefault()
    const tabName = event.currentTarget.dataset.tabName
    this.showTab(tabName)
  }

  showTab(tabName) {
    // Hide all panels
    this.panelTargets.forEach(panel => {
      panel.classList.add("hidden")
    })

    // Remove active state from all tabs
    this.tabTargets.forEach(tab => {
      tab.classList.remove("border-b-2", "border-lavender-600", "text-charcoal", "font-semibold")
      tab.classList.add("text-charcoal-400", "hover:text-charcoal-600")
    })

    // Show selected panel
    const selectedPanel = this.panelTargets.find(panel => panel.dataset.tabPanel === tabName)
    if (selectedPanel) {
      selectedPanel.classList.remove("hidden")
    }

    // Activate selected tab
    const selectedTab = this.tabTargets.find(tab => tab.dataset.tabName === tabName)
    if (selectedTab) {
      selectedTab.classList.remove("text-charcoal-400", "hover:text-charcoal-600")
      selectedTab.classList.add("border-b-2", "border-lavender-600", "text-charcoal", "font-semibold")
    }
  }
}
