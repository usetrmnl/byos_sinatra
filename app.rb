require 'sinatra'
require 'sinatra/activerecord'
require 'dotenv/load'
require 'debug'

require_relative 'config/initializers/tailwind_form'
require_relative 'config/initializers/explicit_forme_plugin'

# allows access on a local network at 192.168.x.x:4567; remove to scope to localhost:4567
set :bind, '0.0.0.0'

# make model, service classes accessible
%w[models services].each do |sub_dir|
  Dir["#{Dir.pwd}/#{sub_dir}/*.rb"].each { |file| require file }
end

helpers do
  def create_forme(model, is_edit, attrs={}, options={})
    attrs[:method] = :post
    options = TailwindConfig.options.merge(options)
    if model && model.persisted?
      attrs[:action] += "/#{@device.id}"
      options[:before] = -> (form) {
        TailwindConfig.before.call(form)
        form.to_s << '<input name="_method" value="patch" type="hidden"/>'
      }
    end
    f = Forme::Form.new(model, options)
    f.extend(ExplicitFormePlugin)
    f.form_tag(attrs)
    return f
  end
end

configure do
  set :json_encoder, :to_json
end

configure :development, :test, :production do
  set :force_ssl, false
end

# DEVICE MANAGEMENT
def devices_form(device)
  create_forme(device, device.persisted?,
        {autocomplete:"off", action: "/devices"},
        {namespace: "device"})
end

get '/' do
    content_type :text
    routes_info = Sinatra::Application.routes.map do |method, routes|
      if method == "HEAD" then
        next
      end
      routes.map { |route| "#{method.ljust(5)} #{route[0]}" }
    end
    routes_info.delete(nil)
    routes_info.flatten.join("\n")
end

get '/devices/?' do
  @devices = Device.all
  erb :"devices/index"
end

get '/devices/new' do
  @device = Device.new
  @form = devices_form(@device)
  erb :"devices/new"
end

get '/devices/:id/delete' do
  @device = Device.find(params[:id])
  @device.destroy
  redirect to('/devices')
end

get '/devices/:id/edit' do
  @device = Device.find(params[:id])
  @form = devices_form(@device)
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
    image_url = "#{ENV['BASE_URL']}/images/setup/setup-logo.bmp"
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
  screen = ScreenFetcher.call

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

puts ""
puts "Serving API at #{ENV['BASE_URL']}"
puts ""
Sinatra::Application.routes.each do |method, routes|
  if method == "HEAD" then
    next
  end

  routes.each do |route|
    pathname = route[0]
    puts "    #{method.ljust(5)} #{pathname}"
  end
end
puts ""
