require_relative "boot"
require "rails/all"

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
  end
end