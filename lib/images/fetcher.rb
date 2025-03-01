# frozen_string_literal: true

require "base64"
require "refinements/pathname"

module Images
  # Fetches image for rendering on device screen.
  class Fetcher
    using Refinements::Pathname

    ALLOWED_ENCRYPTIONS = %i[base_64].freeze

    def initialize allowed_encryptions: ALLOWED_ENCRYPTIONS, environment: ENV
      @allowed_encryptions = allowed_encryptions
      @environment = environment
    end

    def call root_path = Pathname.pwd, encryption: nil
      last_generated_image(root_path, encryption) || default_image
    end

    private

    attr_reader :allowed_encryptions, :environment

    def last_generated_image root_path, encryption
      image_path = root_path.files("*.bmp").max_by(&:ctime)

      return unless image_path

      filename = image_path.basename.to_s

      if allowed_encryptions.include?(encryption) && encryption == :base_64
        {filename:, image_url: "data:image/bmp;base64,#{Base64.strict_encode64 image_path.read}"}
      else
        {filename:, image_url: "#{domain}/images/generated/#{filename}"}
      end
    end

    def default_image
      {filename: "empty_state", image_url: "#{domain}/images/setup/setup-logo.bmp"}
    end

    def domain = environment.fetch "APP_URL"
  end
end
