class ScreenFetcher
  class << self
    def call
      last_generated_image || empty_state_image
    end

    def last_generated_image
      img_path = Dir.glob(File.join(base_path, '*.*')).max { |a, b| File.ctime(a) <=> File.ctime(b) }
      return nil unless img_path

      filename = img_path.split('/').last # => 1as4ff.bmp
      image_url = "#{base_domain}/images/generated/#{filename}"

      { filename:, image_url: }
    end

    def base_domain
      BASE_URL
    end

    def empty_state_image
      "#{base_domain}/images/setup/setup-logo.bmp"
    end

    def base_path
      "#{Dir.pwd}/public/images/generated/"
    end
  end
end
