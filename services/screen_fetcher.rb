require 'active_support/core_ext/string'

module Plugins
  class Base
      def initialize(settings)
      end
  end
end

class ScreenFetcher
  class << self
    def call
      last_generated_image || empty_state_image
    end

    def generate_image_for_plugin(plugin_name)
      plugin = load_plugin(plugin_name)
      return if !plugin

      filename = "filename.bmp"
      image_url = "#{base_domain}/images/plugins/#{plugin_name}/filename.bmp"

      { filename:, image_url: }
    end

    def load_plugin(plugin_name)
      require_relative("../plugins/lib/#{plugin_name}/#{plugin_name}")
      plugin_setting = {} #TODO
      plugin_camelized = plugin_name.camelize
      plugin_cls = ['Plugins', plugin_camelized].inject(Object) { |mod, name| mod.const_get(name) }
      plugin_cls.new(plugin_setting).locals
    end

    def last_generated_image
      img_path = Dir.glob(File.join(base_path, '*.*')).max { |a, b| File.ctime(a) <=> File.ctime(b) }
      return nil unless img_path

      filename = img_path.split('/').last # => 1as4ff.bmp
      image_url = "#{base_domain}/images/generated/#{filename}"

      { filename:, image_url: }
    end

    def base_domain
      ENV['BASE_URL']
    end

    def empty_state_image
      { filename: 'empty_state', image_url: "#{base_domain}/images/setup/setup-logo.bmp" }
    end

    def base_path
      "#{Dir.pwd}/public/images/generated/"
    end
  end
end
