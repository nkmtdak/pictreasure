require_relative "boot"
require "rails/all"
require 'aws-sdk-s3'

Bundler.require(*Rails.groups)

module Pictreasure
  class Application < Rails::Application
    # Rails 7.0のデフォルト設定をロード
    config.load_defaults 7.0

    # Active Jobのキューアダプタを非同期に設定
    config.active_job.queue_adapter = :async

    # Active Storageの画像処理にmini_magickを使用
    config.active_storage.variant_processor = :mini_magick

    # タイムゾーンを東京に設定
    config.time_zone = 'Tokyo'

    # デフォルトのロケールを日本語に設定
    config.i18n.available_locales = [:en, :ja]
    config.i18n.default_locale = :ja

    # アセットのバージョンを設定
    config.assets.version = "1.0"

    # アセットプリコンパイル時の初期化設定（必要に応じて）
    config.assets.initialize_on_precompile = false

    # AWS S3の設定（環境変数から取得）
    config.active_storage.service = :amazon

    # 環境変数からAWS設定を取得（credentialsやdotenvなどで設定）
    config.x.aws_access_key_id = ENV['AWS_ACCESS_KEY_ID']
    config.x.aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    config.x.aws_region = ENV['AWS_REGION']
    config.x.s3_bucket_name = ENV['S3_BUCKET_NAME']
  end
end