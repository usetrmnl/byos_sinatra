# frozen_string_literal: true

require "base64"
require "refinements/pathname"

module Images
  # Fetches image for rendering on device screen.
  class Fetcher
    using Refinements::Pathname

    ALLOWED_ENCRYPTIONS = %i[base_64].freeze

    def initialize encryption: nil, allowed_encryptions: ALLOWED_ENCRYPTIONS, environment: ENV
      @encryption = encryption
      @allowed_encryptions = allowed_encryptions
      @environment = environment
    end

    def call(root_path = Pathname.pwd) = last_generated_image(root_path) || default_image

    private

    attr_reader :encryption, :allowed_encryptions, :environment

    def last_generated_image root_path
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
