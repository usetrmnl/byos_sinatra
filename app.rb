require 'dotenv/load'

require 'sinatra'
require 'sinatra/activerecord'
require 'debug'
require 'uri'

require_relative 'config/initializers/tailwind_form'
require_relative 'config/initializers/explicit_forme_plugin'

# allows access on a local network at 192.168.x.x:4567; remove to scope to localhost:4567
set :bind, '0.0.0.0'
set :port, 4567

# make model, service classes accessible
%w[models services].each do |sub_dir|
  Dir["#{Dir.pwd}/#{sub_dir}/*.rb"].each { |file| require file }
end

helpers do
  def create_forme(model, is_edit, attrs={}, options={})
    attrs[:method] = :post
    options = TailwindConfig.options.merge(options)
    if model && model.persisted?
      attrs[:action] += "/#{model.id}" if model.id
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
  set(:base_url, ENV['BASE_URL'])
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

get '/' do
  @adoptable_devices = UnadoptedDevice.all 

  erb :"index"
end

def is_valid_mac(mac_address)
  return mac_address && mac_address.match(/^[A-Fa-f0-9][048Cc26AaEe][-:]([A-Fa-f0-9]{2}[-:]){4}[A-Fa-f0-9]{2}$/)
end
 
def is_ignored_mac(mac_address)
  ignored_macs = IgnoredMac.find_by_mac_address(mac_address)
  return ignored_macs != nil
end

get '/setup/ignore/:id' do
  unadopted_device = UnadoptedDevice.find(params[:id])

  if unadopted_device
    IgnoredMac.create!({mac_address: unadopted_device.mac_address})
    unadopted_device.destroy
  end

  redirect to('/')
end

get '/setup/adopt/:id' do
  unadopted_device = UnadoptedDevice.find(params[:id])

  if unadopted_device
    unadopted_device.update(adopted: true)
  end

  redirect to('/')
end

# FIRMWARE SETUP
get '/api/setup/' do
  content_type :json
  @device = Device.find_by_mac_address(env['HTTP_ID']) # => ie "41:B4:10:39:A1:24"
  @unadopted_device = UnadoptedDevice.find_by_mac_address(env['HTTP_ID']) # => ie "41:B4:10:39:A1:24"

  status = 404
  api_key = nil
  friendly_id = nil
  image_url = "#{ENV['BASE_URL']}/images/setup/setup-logo.bmp"
  message = "Please adopt this device"

  if @device && @device.adopted
    status = 200
    api_key = @device.api_key
    friendly_id = @device.friendly_id
    image_url = "#{ENV['BASE_URL']}/images/setup/setup-logo.bmp"
    message = "Welcome to TRMNL BYOS"
  elsif @unadopted_device == nil && is_valid_mac(env['HTTP_ID']) && !is_ignored_mac(env['HTTP_ID'])
    Device.create!({
      name: "Device #{env['HTTP_ID']}",
      mac_address: env['HTTP_ID'],
      api_key: '',
      friendly_id: nil,
      adopted: false,
    })
  elsif !env['HTTP_ID']
    message = "MAC Address not registered"
  end
  return status, { status:, api_key:, friendly_id:, image_url:, message: }.to_json
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
    return 404, { status: 404 }.to_json
  end
end

# ERROR MESSAGES
post '/api/log' do
  puts "API/LOG: #{env}"
end
