# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true
pin '@hotwired/stimulus', to: 'stimulus.min.js', preload: true
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true
pin 'application', preload: true
pin 'controllers', to: 'controllers/index.js', preload: true
pin 'controllers/application', to: 'controllers/application.js', preload: true
pin 'controllers/autocomplete_controller', to: 'controllers/autocomplete_controller.js', preload: true
pin 'controllers/validation_controller', to: 'controllers/validation_controller.js', preload: true
pin 'mobile_menu', to: 'mobile_menu.js', preload: true
pin 'chartkick', to: 'https://cdn.skypack.dev/chartkick@5.0.1', preload: true
pin 'chart.js', to: 'https://cdn.skypack.dev/chart.js@4.4.0', preload: true
