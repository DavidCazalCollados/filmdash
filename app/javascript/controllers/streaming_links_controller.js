import { Controller } from "@hotwired/stimulus"
import Swal from 'sweetalert2'

// Connects to data-controller="streaming-links"
export default class extends Controller {
  connect() {
  }

  fetchLinks() {
    // Do call
    // then..
    Swal.fire("SweetAlert2 is working!");
  }
}
