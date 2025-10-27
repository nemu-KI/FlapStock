import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autocomplete"
export default class extends Controller {
  static targets = ["input", "dropdown", "item"]
  static values = {
    url: String,
    field: String,
    minLength: { type: Number, default: 2 },
    maxResults: { type: Number, default: 10 }
  }

  connect() {
    this.hideDropdown()
    this.setupEventListeners()
  }

  disconnect() {
    this.removeEventListeners()
  }

  setupEventListeners() {
    this.inputTarget.addEventListener('input', this.handleInput.bind(this))
    this.inputTarget.addEventListener('keydown', this.handleKeydown.bind(this))
    this.inputTarget.addEventListener('blur', this.handleBlur.bind(this))
    document.addEventListener('click', this.handleDocumentClick.bind(this))
  }

  removeEventListeners() {
    this.inputTarget.removeEventListener('input', this.handleInput.bind(this))
    this.inputTarget.removeEventListener('keydown', this.handleKeydown.bind(this))
    this.inputTarget.removeEventListener('blur', this.handleBlur.bind(this))
    document.removeEventListener('click', this.handleDocumentClick.bind(this))
  }

  handleInput(event) {
    const query = event.target.value.trim()

    if (query.length < this.minLengthValue) {
      this.hideDropdown()
      return
    }

    this.fetchSuggestions(query)
  }

  handleKeydown(event) {
    if (!this.hasDropdownTarget || !this.dropdownTarget.classList.contains('block')) {
      return
    }

    const itemsArray = Array.from(this.dropdownTarget.querySelectorAll('.autocomplete-item'))
    const currentIndex = itemsArray.findIndex(item => item.classList.contains('active'))

    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault()
        this.selectNextItem(itemsArray, currentIndex)
        break
      case 'ArrowUp':
        event.preventDefault()
        this.selectPreviousItem(itemsArray, currentIndex)
        break
      case 'Enter':
        event.preventDefault()
        if (currentIndex >= 0) {
          this.selectItem(itemsArray[currentIndex])
        }
        break
      case 'Escape':
        this.hideDropdown()
        break
    }
  }

  handleBlur(event) {
    // 少し遅延させてクリックイベントを処理
    setTimeout(() => {
      if (!this.dropdownTarget.contains(document.activeElement)) {
        this.hideDropdown()
      }
    }, 150)
  }

  handleDocumentClick(event) {
    if (!this.element.contains(event.target)) {
      this.hideDropdown()
    }
  }

  async fetchSuggestions(query) {
    try {
      const url = new URL(this.urlValue, window.location.origin)
      url.searchParams.set('q', query)
      url.searchParams.set('field', this.fieldValue)
      url.searchParams.set('limit', this.maxResultsValue)

      const response = await fetch(url, {
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const suggestions = await response.json()
      this.displaySuggestions(suggestions)
    } catch (error) {
      // Autocomplete fetch error - silently handle
      this.hideDropdown()
    }
  }

  displaySuggestions(suggestions) {
    if (!suggestions || suggestions.length === 0) {
      this.hideDropdown()
      return
    }

    this.dropdownTarget.innerHTML = ''

    suggestions.forEach((suggestion, index) => {
      const item = document.createElement('div')
      item.className = 'autocomplete-item px-3 py-2 cursor-pointer hover:bg-gray-100 border-b border-gray-100 last:border-b-0'
      item.dataset.autocompleteTarget = 'item'
      item.dataset.index = index
      item.textContent = suggestion.text || suggestion.name || suggestion

      item.addEventListener('click', () => this.selectItem(item))

      this.dropdownTarget.appendChild(item)
    })

    this.showDropdown()
  }

  selectNextItem(items, currentIndex) {
    this.clearActiveItem(items)
    const nextIndex = currentIndex < items.length - 1 ? currentIndex + 1 : 0
    items[nextIndex].classList.add('active', 'bg-blue-50')
  }

  selectPreviousItem(items, currentIndex) {
    this.clearActiveItem(items)
    const prevIndex = currentIndex > 0 ? currentIndex - 1 : items.length - 1
    items[prevIndex].classList.add('active', 'bg-blue-50')
  }

  clearActiveItem(items) {
    items.forEach(item => {
      item.classList.remove('active', 'bg-blue-50')
    })
  }

  selectItem(item) {
    const text = item.textContent
    this.inputTarget.value = text
    this.hideDropdown()

    // カスタムイベントを発火（必要に応じて）
    this.inputTarget.dispatchEvent(new CustomEvent('autocomplete:select', {
      detail: { value: text, item: item },
      bubbles: true
    }))
  }

  showDropdown() {
    this.dropdownTarget.classList.remove('hidden')
    this.dropdownTarget.classList.add('block')
  }

  hideDropdown() {
    this.dropdownTarget.classList.remove('block')
    this.dropdownTarget.classList.add('hidden')
  }
}
