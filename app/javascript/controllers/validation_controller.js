import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="validation"
export default class extends Controller {
  static targets = ["field", "error"]
  static values = {
    url: String,
    field: String
  }

  connect() {
    this.setupValidation()
  }

  setupValidation() {
    this.fieldTargets.forEach(field => {
      field.addEventListener('blur', this.validateField.bind(this))
      field.addEventListener('input', this.clearError.bind(this))
    })
  }

  validateField(event) {
    const field = event.target
    const value = field.value.trim()

    if (value.length === 0) {
      this.showError(field, 'この項目は必須です')
      return
    }

    // 基本的なバリデーション
    if (field.type === 'email' && !this.isValidEmail(value)) {
      this.showError(field, '有効なメールアドレスを入力してください')
      return
    }

    if (field.type === 'tel' && !this.isValidPhone(value)) {
      this.showError(field, '有効な電話番号を入力してください')
      return
    }

    if (field.hasAttribute('minlength')) {
      const minLength = parseInt(field.getAttribute('minlength'))
      if (value.length < minLength) {
        this.showError(field, `少なくとも${minLength}文字以上入力してください`)
        return
      }
    }

    if (field.hasAttribute('maxlength')) {
      const maxLength = parseInt(field.getAttribute('maxlength'))
      if (value.length > maxLength) {
        this.showError(field, `${maxLength}文字以内で入力してください`)
        return
      }
    }

    this.clearError(field)
  }

  clearError(event) {
    const field = event.target
    this.clearFieldError(field)
  }

  showError(field, message) {
    this.clearFieldError(field)

    const errorElement = document.createElement('div')
    errorElement.className = 'text-red-600 text-sm mt-1'
    errorElement.textContent = message
    errorElement.setAttribute('data-validation-target', 'error')

    field.classList.add('border-red-500', 'focus:border-red-500', 'focus:ring-red-500')
    field.classList.remove('border-gray-300', 'focus:border-blue-500', 'focus:ring-blue-500')

    field.parentNode.appendChild(errorElement)
  }

  clearFieldError(field) {
    const existingError = field.parentNode.querySelector('[data-validation-target="error"]')
    if (existingError) {
      existingError.remove()
    }

    field.classList.remove('border-red-500', 'focus:border-red-500', 'focus:ring-red-500')
    field.classList.add('border-gray-300', 'focus:border-blue-500', 'focus:ring-blue-500')
  }

  isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    return emailRegex.test(email)
  }

  isValidPhone(phone) {
    const phoneRegex = /^[\d\-\+\(\)\s]+$/
    return phoneRegex.test(phone) && phone.replace(/\D/g, '').length >= 10
  }
}
