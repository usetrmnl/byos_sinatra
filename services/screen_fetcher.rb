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
  ImagePath = Data.define(:filename, :relative_img_path)

  class << self
    def generated_image(base64, image_path)
      image_url = if base64
                    img = File.open(File.join(public_dir, image_path.relative_img_path))
                    "data:image/png;base64,#{Base64.strict_encode64(img.read)}"
                  else
                    "#{base_domain}/#{image_path.relative_img_path}/#{image_path.filename}"
                  end

      { filename: image_path.filename, image_url: image_url }
    end

    def call(plugin_name, base64)
      generated_image(base64, generate_image_for_plugin(plugin_name) || last_generated_image || empty_state)
    end

    def empty_state_image(base64)
      generated_image(base64, empty_state)
    end

    def empty_state
      ImagePath.new('empty_state', 'images/setup/setup-logo.bmp')
    end

    def generate_image_for_plugin(plugin_name)
      return unless plugin_name

      plugin = load_plugin(plugin_name)
      return unless plugin

      plugin_html = ERB.new(determine_plugin_template(plugin_name))
      gen = ScreenGenerator.new(plugin_html, File.join(Dir.pwd, relative_generated_path, plugin_name))
      gen.process

      ImagePath.new(gen.img_filename, File.join(relative_generated_path, plugin_name))
    end

    def last_generated_image
      full_img_path = Dir.glob(File.join(Dir.pwd, public_dir, relative_generated_path, '*.*')).max do |a, b|
        File.ctime(a) <=> File.ctime(b)
      end
      return nil unless full_img_path

      filename = File.basename(full_img_path) # => 1as4ff.bmp
      relative_img_path = "images/generated/#{filename}"

      ImagePath.new(filename, relative_img_path)
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

    def base_domain
      ENV['BASE_URL']
    end

    def public_dir
      'public'
    end

    def relative_generated_path
      'images/generated'
    end
  end
end
