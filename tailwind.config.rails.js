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
  // Rails用の設定
  corePlugins: {
    preflight: false, // Railsのデフォルトスタイルと競合を避ける
  },
  // 本番環境での最適化
  purge: {
    enabled: Rails.env.production ?,
    content: [
      './app/views/**/*.html.erb',
      './app/helpers/**/*.rb',
      './app/assets/javascripts/**/*.js',
      './app/javascript/**/*.js',
    ],
    // 重要なクラスを保持
    safelist: [
      'lg:static',
      'lg:translate-x-0',
      'lg:hidden',
      'lg:flex',
      '-translate-x-full',
      'translate-x-0',
    ]
  }
}
