require 'openssl'

# Конфігурація зі змінних середовища (Twelve-Factor App)
module Config
  module_function

  def production?
    ENV['RACK_ENV'] == 'production'
  end

  # Обов'язкова змінна: якщо її немає, сервер зупиняється з зрозумілим повідомленням
  def fetch!(key)
    value = ENV[key].to_s.strip
    abort("Не задано змінну середовища #{key}. Дивіться .env.example") if value.empty?
    value
  end

  def database_url
    fetch!('DATABASE_URL')
  end

  # Секрет «розтягується» SHA-512, щоб підпис cookie мав достатню довжину
  def session_secret
    raw = fetch!('SESSION_SECRET')
    abort('SESSION_SECRET занадто короткий (мінімум 32 символи)') if production? && raw.length < 32
    OpenSSL::Digest::SHA512.hexdigest(raw)
  end

  def port
    ENV.fetch('PORT', '4567').to_i
  end

  def metrics_token
    ENV['METRICS_TOKEN'].to_s
  end

  def version
    (ENV['RENDER_GIT_COMMIT'] || 'dev')[0, 7]
  end
end
