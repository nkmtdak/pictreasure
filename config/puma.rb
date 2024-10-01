max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Renderではdevelopment環境は使用しないため、この行は削除しても構いません
# worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

port ENV.fetch("PORT") { 3000 }

# Render環境ではproductionを使用するため、デフォルトをproductionに変更
environment ENV.fetch("RAILS_ENV") { "production" }

pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Renderの無料プランでは1ワーカーが推奨されるため、デフォルトを1に変更
workers ENV.fetch("WEB_CONCURRENCY") { 1 }

preload_app!

plugin :tmp_restart