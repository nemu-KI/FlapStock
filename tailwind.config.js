module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/javascripts/**/*.js',
    './app/javascript/**/*.js',
  ],
  theme: {
    extend: {
      colors: {
        flapstockBlue: '#5AC8FA',
        flapstockNavy: '#2D3A6B',
        flapstockSilver: '#E3E9F3',
        flapstockPink: '#F7B6C2',
        flapstockWhite: '#F9FAFB',
      },
    },
  },
  plugins: [],
}
