# frozen_string_literal: true

class ScreenFetcher
  class << self
    attr_reader :base64

    def call(base64: false)
      @base64 = base64
      last_generated_image || empty_state_image
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
