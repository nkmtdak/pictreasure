require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Pictreasure
  class Application < Rails::Application

    config.load_defaults 7.0
    config.active_job.queue_adapter = :async
    config.active_storage.variant_processor = :mini_magick
    # Sassの設定を追加
    config.sass.load_paths << Rails.root.join('app', 'assets', 'stylesheets')
    config.sass.preferred_syntax = :scss

  end
end
