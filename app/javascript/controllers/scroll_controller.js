import { Controller } from "@hotwired/stimulus"

// Keeps the message list pinned to the newest message on connect and after
// Turbo swaps the frame.
export default class extends Controller {
  connect() {
    this.scrollToBottom()
  }

  scrollToBottom() {
    this.element.scrollTop = this.element.scrollHeight
  }
}
