import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="result-movie"
export default class extends Controller {
  static targets = ["infos", "detailsone"]
  static classes = ["hide"]

  connect() {
  }

  toggle() {
    this.infosTarget.classList.toggle(this.hideClass);
  }
}
