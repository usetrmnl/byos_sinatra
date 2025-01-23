class ScreenFetcher
  class << self
    def call(app)
      last_generated_image(app) || empty_state_image(app)
    end

    def last_generated_image(app)
      img_path = Dir.glob(File.join(base_path, '*.*')).max { |a, b| File.ctime(a) <=> File.ctime(b) }
      return nil unless img_path

      filename = img_path.split('/').last # => 1as4ff.bmp
      image_url = app.url_for("/images/generated/#{filename}")

      { filename:, image_url: }
    end

    def empty_state_image(app)
      image_url =  app.url_for("/images/setup/setup-logo.bmp")
      { filename: 'empty_state', image_url: image_url }
    end

    def base_path
      "#{Dir.pwd}/public/images/generated/"
    end
  end
end
