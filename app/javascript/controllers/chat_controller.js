import { Controller } from "@hotwired/stimulus"

// Drives the chat conversation: submits the composer without a full-page
// reload, streams the provider reply into a growing assistant bubble, and
// persists the exchange server-side.
export default class extends Controller {
  static targets = ["conversation", "messages", "form", "input", "sendButton"]

  connect() {
    this.pending = false
  }

  // Composer submit: append the user bubble, POST, then stream the reply.
  async send(event) {
    event.preventDefault()
    if (this.pending) return
    const content = this.inputTarget.value.trim()
    if (!content) return

    this.pending = true
    this.inputTarget.value = ""
    this.resizeInput()
    this.appendMessage("user", content)
    this.disableComposer(true)

    const conversationId = this.conversationTarget.dataset.conversationId
    const url = `/conversations/${conversationId}/messages`
    const body = new URLSearchParams({ message: content })

    try {
      const response = await fetch(url, {
        method: "POST",
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "Accept": "text/plain, text/html"
        },
        body
      })

      if (!response.ok) {
        this.appendMessage("assistant", "Something went wrong sending that message. Try again.")
        return
      }

      const reader = response.body.getReader()
      const decoder = new TextDecoder()
      let buffer = ""

      while (true) {
        const { done, value } = await reader.read()
        if (done) break
        buffer += decoder.decode(value, { stream: true })
        this.updateAssistantBubble(buffer)
      }
    } catch (error) {
      this.appendMessage("assistant", "Network error — your message was saved, but the reply didn't come through.")
    } finally {
      this.pending = false
      this.disableComposer(false)
      this.inputTarget.focus()
    }
  }

  submitOnEnter(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      this.formTarget.requestSubmit()
    }
  }

  appendMessage(role, content) {
    const wrapper = document.createElement("div")
    wrapper.className = `emberline-message emberline-message--${role}`
    wrapper.dataset.role = role
    const bubble = document.createElement("div")
    bubble.className = "emberline-message__bubble"
    bubble.textContent = content
    wrapper.appendChild(bubble)
    this.messagesTarget.appendChild(wrapper)
    this.scrollToBottom()
  }

  updateAssistantBubble(text) {
    let bubble = this.messagesTarget.querySelector(".emberline-message--assistant .emberline-message__bubble:last-of-type")
    if (!bubble) {
      const wrapper = document.createElement("div")
      wrapper.className = "emberline-message emberline-message--assistant"
      wrapper.dataset.role = "assistant"
      bubble = document.createElement("div")
      bubble.className = "emberline-message__bubble"
      wrapper.appendChild(bubble)
      this.messagesTarget.appendChild(wrapper)
    }
    bubble.textContent = text
    this.scrollToBottom()
  }

  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  disableComposer(disabled) {
    this.inputTarget.disabled = disabled
    this.sendButtonTarget.disabled = disabled
    this.sendButtonTarget.setAttribute("aria-busy", String(disabled))
  }

  resizeInput() {
    this.inputTarget.style.height = "auto"
    this.inputTarget.style.height = `${Math.min(this.inputTarget.scrollHeight, 160)}px`
  }
}
