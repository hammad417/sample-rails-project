
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # This origin will be replaced by comma seperated list of origins provided by mulax client
    # https://github.com/cyu/rack-cors/issues/178
    origins  '*'
    resource '*', headers: :any, methods: [:get, :post, :delete, :put, :patch, :options, :head]
  end
end