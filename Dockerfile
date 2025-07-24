FROM ruby:3.2.3-slim

ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        build-essential \
        libpq-dev \
        git \
        python3

# Node.js 18 (NodeSource公式推奨のsetupスクリプトを利用)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -

# Yarn公式リポジトリ追加
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/yarnkey.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list

RUN apt-get update -qq \
    && apt-get install -y nodejs yarn \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN gem install bundler:2.4.19

COPY Gemfile Gemfile.lock ./
RUN bundle install

# package.json/yarn.lockが無い場合はこの行をコメントアウトしてOK
# COPY package.json yarn.lock ./
# RUN if [ -f yarn.lock ]; then yarn install; fi

COPY . .

EXPOSE 3000

CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bundle exec rails server -b 0.0.0.0"]
