require 'active_support/core_ext/string'
require 'puppeteer-ruby'


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

      plugin_html = ERB.new(determine_plugin_template(plugin_name))
      gen = ScreenGenerator.new(plugin_html, File.join(base_path, "#{plugin_name}"))
      gen.process
      filename = gen.img_filename

      image_url = "#{generated_base_url}/#{plugin_name}/#{filename}"

      { filename:, image_url: }
    end

    def determine_plugin_template(plugin_name)
      "../plugins/lib/#{plugin_name}/#{plugin_name}/views/full.html.erb"
    end

    def load_plugin(plugin_name)
      require_relative("../plugins/lib/#{plugin_name}/#{plugin_name}")
      plugin_setting = {} #TODO
      plugin_camelized = plugin_name.camelize
      plugin_cls = ['Plugins', plugin_camelized].inject(Object) { |mod, name| mod.const_get(name) }
      plugin_cls.new(plugin_setting)
    end
     
    def last_generated_image
      img_path = Dir.glob(File.join(base_path, '*.*')).max { |a, b| File.ctime(a) <=> File.ctime(b) }
      return nil unless img_path

      filename = img_path.split('/').last # => 1as4ff.bmp
      image_url = "#{generated_base_url}/#{filename}"

      { filename:, image_url: }
    end

    def base_domain
      ENV['BASE_URL']
    end

    def empty_state_image
      { filename: 'empty_state', image_url: "#{base_domain}/images/setup/setup-logo.bmp" }
    end

    def generated_base_url
      "#{base_domain}/images/generated"
    end

    def base_path
      "#{Dir.pwd}/public/images/generated"
    end
  end
end
