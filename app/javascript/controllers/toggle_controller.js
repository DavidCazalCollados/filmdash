import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle"
export default class extends Controller {
  static targets = ["appear1Element",
                    "play1Element",
                    "appear2Element",
                    "play2Element",
                    "appear3Element",
                    "play3Element",
                    "container1Element",
                    "container2Element",
                    "container3Element"
                  ]

  connect() {
    console.log("Hello");
    document.addEventListener("click", this.handleOutsideClick.bind(this));

  }

  disconnect () {
    document.removeEventListener("click", this.handleOutsideClick.bind(this));
  }

  handleOutsideClick(event) {

    if (
      !this.container1ElementTarget.contains(event.target) &&
      !this.container2ElementTarget.contains(event.target) &&
      !this.container3ElementTarget.contains(event.target)
    ) {
      this.closeAll();
    }
  }

  closeAll() {
    this.appear1ElementTarget.classList.add("d-none");
    this.play1ElementTarget.classList.add("d-none");
    this.container1ElementTarget.classList.remove("justify-content-between");
    this.container1ElementTarget.classList.add("justify-content-center");

    this.appear2ElementTarget.classList.add("d-none");
    this.play2ElementTarget.classList.add("d-none");
    this.container2ElementTarget.classList.remove("justify-content-between");
    this.container2ElementTarget.classList.add("justify-content-center");

    this.appear3ElementTarget.classList.add("d-none");
    this.play3ElementTarget.classList.add("d-none");
    this.container3ElementTarget.classList.remove("justify-content-between");
    this.container3ElementTarget.classList.add("justify-content-center");
  }

  button1 () {
    // event.target.classList.add("movie-card-dark")
    this.closeAll();
    this.appear1ElementTarget.classList.remove("d-none");
    this.play1ElementTarget.classList.remove("d-none");
    this.container1ElementTarget.classList.remove("justify-content-center");
    this.container1ElementTarget.classList.add("justify-content-between");
    // this.togglableElementTarget.classList.toggle("d-none");
  }

  button2 () {
    this.closeAll();
    this.appear2ElementTarget.classList.remove("d-none");
    this.play2ElementTarget.classList.remove("d-none");
    this.container2ElementTarget.classList.remove("justify-content-center");
    this.container2ElementTarget.classList.add("justify-content-between");
  }

  button3 () {
    this.closeAll();
    this.appear3ElementTarget.classList.remove("d-none");
    this.play3ElementTarget.classList.remove("d-none");
    this.container3ElementTarget.classList.remove("justify-content-center");
    this.container3Element.classList.add("justify-content-between");
  }

  refresh() {
    window.location.reload();
  }
}
