require_relative "boot"
require "rails/all"
require "dartsass-rails"

Bundler.require(*Rails.groups)

module Pictreasure
  class Application < Rails::Application
    config.load_defaults 7.0
    config.active_job.queue_adapter = :async
    config.active_storage.variant_processor = :mini_magick


    # Sassの設定（dartsass-railsを使用している場合）
    config.assets.css_compressor = nil
    config.dartsass.builds = {
      "application.scss" => "application.css"
    }
    config.dartsass.build_options = {
      load_path: [Rails.root.join('app', 'assets', 'stylesheets')]
    }
  end
end