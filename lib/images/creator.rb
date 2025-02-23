# frozen_string_literal: true

module Images
  # Creates device image.
  class Creator
    def initialize screensaver: Screensaver.new, greyscaler: Greyscaler.new
      @screensaver = screensaver
      @greyscaler = greyscaler
    end

    def call content, output_path = Bundler.root.join("public/images/generated/%<name>s.bmp")
      Tempfile.create %w[creator- .jpg] do |file|
        path = file.path

        screensaver.call content, path
        greyscaler.call path, output_path
      end
    end

    private

    attr_reader :screensaver, :greyscaler
  end
end
