import { Application } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails";
// import "./tmdb_search_controller"

Turbo.setFormMode("on")

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
