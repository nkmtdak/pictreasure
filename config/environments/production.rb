require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"
  config.eager_load = true

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Include generic and useful information about system operation, but avoid logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII).
  config.log_level = :info

  config.assets.css_compressor = nil

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new
  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  config.assets.digest = true

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end
end

