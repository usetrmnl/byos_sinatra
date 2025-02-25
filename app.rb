# frozen_string_literal: true

require_relative "config/application"

module TRMNL
  class Application < Sinatra::Base
    def self.loader registry = Zeitwerk::Registry
      @loader ||= registry.loaders.find { |loader| loader.tag == "trmnl-application" }
    end

    configure :production do
      base_url = URI.parse ENV.fetch "APP_URL"
      use Rack::Protection::HostAuthorization, permitted_hosts: [base_url.host]
    end

    configure do
      set :json_encoder, :to_json
      set :base_url, ENV.fetch("APP_URL")
      set :views, Bundler.root.join("app/templates")
    end

    configure :development, :test, :production do
      set :force_ssl, false
    end

    get "/" do
      Views::Home::Show.new.call.to_s
    end

    get "/devices" do
      view = Views::Devices::Index.new
      view.call(devices: Device.all).to_s
    end

    post "/devices" do
      device = Device.create! params[:device]
      view = Views::Devices::Show.new

      view.call(device:, layout: false).to_s
    end

    get "/devices/new" do
      view = Views::Devices::New.new
      view.call(device: Device.new, layout: false).to_s
    end

    get "/devices/:id/edit" do
      device = Device.find params[:id]
      view = Views::Devices::Edit.new
      view.call(device:).to_s
    end

    get "/devices/:id" do
      device = Device.find params[:id]
      view = Views::Devices::Show.new

      view.call(device:).to_s
    end

    put "/devices/:id" do
      device = Device.find params[:id]
      view = Views::Devices::Show.new

      device.update! params[:device]
      view.call(device:).to_s
    end

    delete "/devices/:id" do
      Device.find(params[:id]).destroy!
      body ""
    end

    get "/api/setup/" do
      content_type :json
      @device = Device.find_by_mac_address env["HTTP_ID"] # => ie "41:B4:10:39:A1:24"

      if @device
        status = 200
        api_key = @device.api_key
        friendly_id = @device.friendly_id
        image_url = %(#{ENV.fetch "APP_URL"}/images/setup/setup-logo.bmp)
        message = "Welcome to TRMNL BYOS"

        {status:, api_key:, friendly_id:, image_url:, message:}.to_json
      else
        {
          status: 404,
          api_key: nil,
          friendly_id: nil,
          image_url: nil,
          message: "MAC Address not registered"
        }.to_json
      end
    end

    get "/api/display/" do
      content_type :json
      @device = Device.find_by_api_key env["HTTP_ACCESS_TOKEN"]

      if @device
        encryption = :base_64 if (env["HTTP_BASE64"] || params[:base64]) == "true"
        screen = Images::Fetcher.new(encryption:).call Pathname.pwd.join("public/images/generated")

        {
          # FIX: On Core, a 202 status loops device back to /api/setup unless User is connected.
          status: 0,
          image_url: screen[:image_url],
          filename: screen[:filename],
          refresh_rate: @device.refresh_interval,
          reset_firmware: false,
          update_firmware: false,
          firmware_url: nil,
          special_function: "sleep"
        }.to_json
      else
        {status: 404}.to_json
      end
    end

    post "/api/log" do
      puts "API/LOG: #{env}"
    end
  end
end
