# frozen_string_literal: true

require 'active_support/core_ext/string'
require 'puppeteer-ruby'

module Plugins
  # Base class for plugins
  class Base
    def initialize(settings) end
  end
end

# Generates images with ScreenGenerator for a given plugin and returns
# where the newly generated image is
class ScreenFetcher
  class << self
    attr_reader :base64

    def call(base64: false)
      @base64 = base64
      last_generated_image || empty_state_image
    end

    def generate_image_for_plugin(plugin_name)
      plugin = load_plugin(plugin_name)
      return unless plugin

      plugin_html = ERB.new(determine_plugin_template(plugin_name))
      gen = ScreenGenerator.new(plugin_html, File.join(base_path, plugin_name))
      gen.process
      filename = gen.img_filename

      image_url = "#{generated_base_url}/#{plugin_name}/#{filename}"

      { filename: filename, image_url: image_url }
    end

    def determine_plugin_template(plugin_name)
      "../plugins/lib/#{plugin_name}/#{plugin_name}/views/full.html.erb"
    end

    def load_plugin(plugin_name)
      require_relative("../plugins/lib/#{plugin_name}/#{plugin_name}")
      plugin_setting = {} # TODO
      plugin_camelized = plugin_name.camelize
      plugin_cls = ['Plugins', plugin_camelized].inject(Object) { |mod, name| mod.const_get(name) }
      plugin_cls.new(plugin_setting)
    end

    def last_generated_image
      full_img_path = Dir.glob(File.join(base_path, '*.*')).max { |a, b| File.ctime(a) <=> File.ctime(b) }
      return nil unless full_img_path

      filename = File.basename(full_img_path) # => 1as4ff.bmp
      relative_img_path = "images/generated/#{filename}"

      image_url = if base64
                    img = File.open("public/#{relative_img_path}")
                    "data:image/png;base64,#{Base64.strict_encode64(img.read)}"
                  else
                    "#{base_domain}/#{relative_img_path}"
                  end

      { filename: filename, image_url: image_url }
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
