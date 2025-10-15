# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true
pin 'application', preload: true
pin 'chartkick', to: 'https://cdn.skypack.dev/chartkick@5.0.1', preload: true
pin 'chart.js', to: 'https://cdn.skypack.dev/chart.js@4.4.0', preload: true
