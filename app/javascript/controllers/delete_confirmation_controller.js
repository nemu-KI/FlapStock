import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
  }

  confirm(event) {
    const message = event.currentTarget.dataset.confirm

    if (!window.confirm(message)) {
      event.preventDefault()
      event.stopPropagation()
      return false
    }
  }
}
