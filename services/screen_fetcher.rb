# frozen_string_literal: true

class ScreenFetcher
  attr_reader :base64

  def self.call base64: false
    @base64 = base64
    last_generated_image || empty_state_image
  end

  def self.find_last_updated_file
    Dir.glob(File.join(base_path, '*.*')).max { |a, b| File.ctime(a) <=> File.ctime(b) }
  end

  def self.last_generated_image
    full_img_path = find_last_updated_file
    return nil unless full_img_path

    filename = File.basename(full_img_path) # => 1as4ff.bmp
    relative_img_path = "images/generated/#{filename}"

    image_url = if @base64
                  img = File.open("public/#{relative_img_path}")
                  "data:image/png;base64,#{Base64.strict_encode64(img.read)}"
                else
                  "#{base_domain}/#{relative_img_path}"
                end

    { filename: filename, image_url: image_url }
  end

  def self.base_domain = ENV["BASE_URL"]

  def self.base_path = "#{Dir.pwd}/public/images/generated/"

  def self.empty_state_image
    {filename: "empty_state", image_url: "#{base_domain}/images/setup/setup-logo.bmp"}
  end
end
