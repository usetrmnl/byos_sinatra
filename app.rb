require 'sinatra'
require 'sinatra/activerecord'
require 'debug'

require_relative 'config/initializers/tailwind_form'

# allows access on a local network at 192.168.x.x:4567; remove to scope to localhost:4567
set :bind, '0.0.0.0'

current_dir = Dir.pwd
Dir["#{current_dir}/models/*.rb"].each { |file| require file } # require models
Dir["#{current_dir}/services/*.rb"].each { |file| require file } # require services

helpers do
  def url_for(path = '', options = {})
    scheme = options[:scheme] || request.scheme
    host = options[:host] || request.host
    port = options[:port] || request.port

    base = "#{scheme}://#{host}"
    if scheme == "http"
      base += ":#{port}" unless port == 80
    elsif scheme == "https"
      base += ":#{port}" unless port == 443
    end

    URI.join(base, path).to_s
  end

  def edit_forme(model, attrs, options, &block)
    attrs[:action] += "/#{@device.id}"
    options[:before] = -> (form) {
      TailwindConfig.before.call(form)
      form.to_s << '<input name="_method" value="patch" type="hidden"/>'
    }
    Forme.form(model, attrs, options, &block)
  end

  def create_forme(model, is_edit, attrs={}, options={}, &block)
    attrs[:method] = :post
    options = TailwindConfig.options.merge(options)
    if model && model.persisted?
      return edit_forme(model, attrs, options, &block)
    end
    return Forme.form(model, attrs, options, &block)
  end

end

configure do
  set :json_encoder, :to_json
end

configure :development, :test, :production do
  set :force_ssl, false
end

# DEVICE MANAGEMENT
get '/devices/?' do
  @devices = Device.all
  erb :"devices/index"
end

get '/devices/new' do
  @device = Device.new
  erb :"devices/new"
end

get '/devices/:id/delete' do
  @device = Device.find(params[:id])
  @device.destroy
  redirect to('/devices')
end

get '/devices/:id/edit' do
  @device = Device.find(params[:id])
  erb :"devices/edit"
end

patch '/devices/:id' do
  device = Device.find(params[:id])
  device.update(params[:device])
  redirect to('/devices')
end

post '/devices' do
  Device.create!(params[:device])
  redirect to('/devices')
end

# FIRMWARE SETUP
get '/api/setup/' do
  content_type :json
  @device = Device.find_by_mac_address(env['HTTP_ID']) # => ie "41:B4:10:39:A1:24"

  if @device
    status = 200
    api_key = @device.api_key
    friendly_id = @device.friendly_id
    image_url = url_for("/images/setup/setup-logo.bmp")
    message = "Welcome to TRMNL BYOS"

    { status:, api_key:, friendly_id:, image_url:, message: }.to_json
  else
    { status: 404, api_key: nil, friendly_id: nil, image_url: nil, message: 'MAC Address not registered' }.to_json
  end
end

# DISPLAY CONTENT
get '/api/display/' do
  content_type :json
  @device = Device.find_by_api_key(env['HTTP_ACCESS_TOKEN'])
  screen = ScreenFetcher.call(self)

  if @device
    {
      status: 0, # on core TRMNL server, status 202 loops device back to /api/setup unless User is connected, which doesn't apply here
      image_url: screen[:image_url],
      filename: screen[:filename],
      refresh_rate: @device.refresh_interval,
      reset_firmware: false,
      update_firmware: false,
      firmware_url: nil,
      special_function: 'sleep'
    }.to_json
  else
    { status: 404 }.to_json
  end
end

# ERROR MESSAGES
post '/api/log' do
  puts "API/LOG: #{env}"
end
