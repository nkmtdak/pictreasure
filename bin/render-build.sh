#!/usr/bin/env bash
# exit on error
set -o errexit

# 環境変数の設定
export RAILS_ENV=production
export NODE_ENV=production

# Install dependencies
bundle install

# Clean assets and clear cache
bundle exec rake assets:clobber
bundle exec rake tmp:clear

# Dart Sassのビルドを実行
bundle exec rake dartsass:build

# Compile assets
bundle exec rake assets:precompile

# Run database migrations
bundle exec rake db:migrate