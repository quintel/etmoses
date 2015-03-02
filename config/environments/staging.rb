require File.expand_path(File.dirname(__FILE__)) + '/production'

Rails.application.configure do
  # Temporarily use in-memory caching.
  config.cache_store = :memory_store, { size: 64.megabytes }
end
