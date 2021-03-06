Medlink::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.public_file_server.enabled = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  config.assets.precompile += %w( font-awesome-ie7.min.css )

  # Disable delivery errors, bad email addresses will be ignored
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default :charset => "utf-8"
  config.action_mailer.default_url_options = { host: 'pcmedlink.org' }

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.eager_load = true

  config.log_level = :info

  config.active_job.queue_adapter = :sidekiq

  config.after_initialize do
    Bullet.enable  = true
    Bullet.rollbar = true
  end

  Rails.application.routes.default_url_options[:host] = "pcmedlink.org"

  bot_opts = {
    username:   ENV.fetch("SLACK_BOT_NAME", "Medlink"),
    icon_emoji: ":hospital:"
  }

  config.container.slackbot { Medlink::Slackbot.build bot_opts.merge channel: "#medlink"      }
  config.container.pingbot  { Medlink::Slackbot.build bot_opts.merge channel: "#medlink-logs" }
  config.container.slow_request_notifier do
    SlowRequestNotifier.build notifier: config.container.resolve(:notifier)
  end
  config.container.sms_deliverer do
    ->(sms:, twilio:) { twilio.client.messages.create sms if twilio.client }
  end
end
