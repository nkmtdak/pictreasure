Rails.application.config.dartsass.builds = {
  "application.scss" => "application.css"
}

Rails.application.config.dartsass.build_options = "--style=compressed --load-path=#{Rails.root.join('app', 'assets', 'stylesheets')}"
Rails.application.config.dartsass.source_map = false