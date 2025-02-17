require 'ferrum'
require 'mini_magick'
require 'puppeteer-ruby'
require 'base64'

class ScreenGenerator
  def initialize(html, output_image_path)
    self.input = html
    FileUtils.mkdir_p(output_image_path) unless File.exist?(output_image_path)
    self.img_filename = "#{SecureRandom.hex(3)}.bmp"
    self.img_path = File.join(output_image_path, img_filename)
  end

  attr_accessor :input, :img_path, :img_filename, :output, :processor

  def process
    convert_to_image
    return unless output

    mono_image(output)
    IO.copy_stream(output, img_path)
  end

  private

  # Constructs the command and passes the input to the vendor/puppeteer.js
  # script for processing. Returns a base64 encoded string
  def convert_to_image
    retry_count = 0
    begin
      # context = browser_instance.create_incognito_browser_context
      page = firefox_browser.new_page
      page.viewport = Puppeteer::Viewport.new(width: width, height: height)
      # NOTE: Use below for chromium
      # page.set_content(input, wait_until: ['networkidle0', 'domcontentloaded'])
      # Note: Use below for firefox
      page.set_content(input, timeout: 10_000)
      page.evaluate(<<~JAVASCRIPT)
        () => {
          document.getElementsByTagName('html')[0].style.overflow = "hidden";
          document.getElementsByTagName('body')[0].style.overflow = "hidden";
        }
      JAVASCRIPT
      self.output = Tempfile.new
      page.screenshot(path: output.path, type: 'png')
      firefox_browser.close
    end
  rescue Puppeteer::TimeoutError, Puppeteer::FrameManager::NavigationError => e
    retry_count += 1
    firefox_browser.close
    if retry_count <= 1
      @browser = nil
      retry
    else
      puts "ERROR -> Converter::Html#convert_to_image_by_firefox -> #{e.message}"
    end
  end

  # Refer this PR where the author reused the browser instance https://github.com/YusukeIwaki/puppeteer-ruby/pull/100/files
  # This will increase the throughput of our image rendering process by 60-70%, saving about ~1.5 second per image generation.
  # On local it takes < 1 second now to generate the subsequent image.
  def firefox_browser
    @firefox_browser ||= Puppeteer.launch(
      product: 'firefox',
      headless: true,
      args: [
        "--window-size=#{width},#{height}",
        '--disable-web-security'
        # "--hide-scrollbars" #works only on chrome, using page.evaluate for firefox
      ]
    )
  end

  def Ferrum.cached_browser
    return nil unless $cached_browser

    $cached_browser
  end

  def Ferrum.cached_browser=(value)
    $cached_browser = value
  end

  # Overall at max wait for 2.5 seconds
  def wait_for_stop_loading(page)
    count = 0
    while page.frames.first.state != :stopped_loading && count < 20
      count += 1
      sleep 0.1
    end
    sleep 0.5 # wait_until: DomContentLoaded event is not available in ferrum
  end

  def mono(img)
    MiniMagick::Tool::Convert.new do |m|
      m << img.path
      m.monochrome # Use built-in smart monochrome dithering (but it's not working as expected)
      m.depth(color_depth) # Should be set to 1 for 1-bit output
      m.strip # Remove any additional metadata
      m << ('bmp3:' << img.path)
    end
  end

  def mono_image(img)
    # Changelog:
    # ImageMagick 6.XX used to convert the png to bitmap with dithering while maintaining the channel to 1
    # The same seems to be broken with imagemagick 7.XX
    # So in order to reduce the channel from 8 to 1, I just rerun the command, and it's working
    # TODO for future, find a better way to generate image screens.
    MiniMagick::Tool::Convert.new do |m|
      m << img.path
      m.dither << 'FloydSteinberg'
      m.remap << 'pattern:gray50'
      m.depth(color_depth) # Should be set to 1 for 1-bit output
      m.strip # Remove any additional metadata
      m << format('bmp3:' << img.path) # Converts to Bitmap.
    end
    MiniMagick::Tool::Convert.new do |m|
      m << img.path
      m.dither << 'FloydSteinberg'
      m.remap << 'pattern:gray50'
      m.depth(color_depth) # Should be set to 1 for 1-bit output
      m.strip # Remove any additional metadata
      m << ('bmp3:' << img.path) # Converts to Bitmap.
    end
  end

  def width
    device[:width]
  end

  def height
    device[:height]
  end

  def color_depth
    device[:color_depth]
  end

  def device
    @device ||= Device::MODEL.first
  end
end
