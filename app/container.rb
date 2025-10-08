# frozen_string_literal: true

require "cogger"
require "containable"

# The application container.
module Container
  extend Containable

  register :log_keys do
    YAML.safe_load_file(Bundler.root.join("config/log_keys.yml"), symbolize_names: true)
        .fetch :allowed
  end

  register :logger do
    Cogger.add_filters(:api_key, "HTTP_ACCESS_TOKEN").new id: :trmnl, formatter: :json
  end
end
