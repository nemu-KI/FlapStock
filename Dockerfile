FROM ruby:3.2.3-slim

# 必要なパッケージをインストール
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    libpq-dev \
    nodejs \
    yarn \
    git

# 作業ディレクトリを作成
WORKDIR /app

# GemfileとGemfile.lockを先にコピーしてbundle install
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install

# アプリケーションの全ファイルをコピー
COPY . .

# ポート3000を公開
EXPOSE 3000

# サーバ起動時にPIDファイルが残っていたら削除し、Railsサーバを起動
CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bundle exec rails server -b 0.0.0.0"]
