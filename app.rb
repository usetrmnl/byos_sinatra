# frozen_string_literal: true

require_relative "config/application"

module TRMNL
  # rubocop:todo Metrics/ClassLength
  class Application < Sinatra::Base
    def self.loader registry = Zeitwerk::Registry
      @loader ||= registry.loaders.find { |loader| loader.tag == "trmnl-application" }
    end

    configure :production do
      base_url = URI.parse ENV.fetch "APP_URL"
      use Rack::Protection::HostAuthorization, permitted_hosts: [base_url.host]
    end

    # rubocop:todo Metrics/AbcSize
    # rubocop:todo Metrics/MethodLength
    helpers do
      # rubocop:todo Metrics/ParameterLists
      # rubocop:todo Style/OptionHash
      def create_forme model, _is_edit, attrs = {}, options = {}
        attrs[:method] = :post
        options = TailwindConfig.options.merge options

        # rubocop:todo Style/MissingElse
        if model && model.persisted?
          attrs[:action] += "/#{model.id}" if model.id

          options[:before] = lambda do |form|
            TailwindConfig.before.call form
            form.to_s << '<input name="_method" value="patch" type="hidden"/>'
          end
        end
        # rubocop:enable Style/MissingElse
        # rubocop:enable Style/OptionHash

        f = Forme::Form.new model, options
        f.extend ExplicitFormePlugin
        f.form_tag attrs
        f
      end
      # rubocop:enable Metrics/ParameterLists
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    configure do
      set :json_encoder, :to_json
      set :base_url, ENV.fetch("APP_URL")
      set :views, Bundler.root.join("app/templates")
    end

    configure :development, :test, :production do
      set :force_ssl, false
    end

    get "/devices/?" do
      @devices = Device.all
      erb :"devices/index"
    end

    get "/devices/new" do
      @device = Device.new
      erb :"devices/new"
    end

    get "/devices/:id/delete" do
      @device = Device.find params[:id]
      @device.destroy
      redirect to(%(#{ENV.fetch "APP_URL"}/devices))
    end

    get "/devices/:id/edit" do
      @device = Device.find params[:id]
      erb :"devices/edit"
    end

    patch "/devices/:id" do
      device = Device.find params[:id]
      device.update params[:device]
      redirect to(%(#{ENV.fetch "APP_URL"}/devices))
    end

    post "/devices" do
      Device.create! params[:device]
      redirect to(%(#{ENV.fetch "APP_URL"}/devices))
    end

    get "/" do
      erb :index
    end

    # FIRMWARE SETUP
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

    # DISPLAY CONTENT
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

    # ERROR MESSAGES
    post "/api/log" do
      puts "API/LOG: #{env}"
    end
  end
  # rubocop:enable Metrics/ClassLength
end
