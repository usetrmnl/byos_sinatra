require 'dotenv/load'

require 'sinatra'
require 'sinatra/activerecord'
require 'debug'
require 'uri'

require_relative 'config/initializers/tailwind_form'
require_relative 'config/initializers/subform_plugin'
require_relative 'config/initializers/explicit_forme_plugin'

# allows access on a local network at 192.168.x.x:4567; remove to scope to localhost:4567
set :bind, '0.0.0.0'
set :port, 4567

configure :production do
  base_url = URI.parse(ENV['BASE_URL'])
  use Rack::Protection::HostAuthorization, permitted_hosts: [base_url.host]
end

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
    f.extend(SubformsPlugin)
    f.extend(ExplicitFormePlugin)
    f.form_tag(attrs)
    return f
  end
end

configure do
  set :json_encoder, :to_json
  set :base_url, ENV['BASE_URL']
end

configure :development, :test, :production do
  set :force_ssl, false
end

# DEVICE MANAGEMENT
def devices_form(device)
  create_forme(device, device.persisted?,
        {autocomplete:"off", action: "#{ENV['BASE_URL']}/devices"},
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
  redirect to("#{ENV['BASE_URL']}/devices")
end

get '/devices/:id/edit' do
  @device = Device.find(params[:id])
  @form = devices_form(@device)
  erb :"devices/edit"
end

patch '/devices/:id' do
  device = Device.find(params[:id])
  device.update(params[:device])
  redirect to("#{ENV['BASE_URL']}/devices")
end

post '/devices' do
  Device.create!(params[:device])
  redirect to("#{ENV['BASE_URL']}/devices")
end

get '/' do
  @BASE_URL = ENV['BASE_URL']
  erb :"index"
end

# SCHEDULE MANAGEMENT
def schedules_form(schedule)
  create_forme(schedule, schedule.persisted?,
        {autocomplete:"off", action: "#{ENV['BASE_URL']}/schedules"},
        {namespace: "schedule"})
end

get '/schedules/?' do
  @active_schedules = ActiveSchedule.all
  @schedules = Schedule.all
  @devices = Device.all
  erb :"schedules/index"
end

get '/schedules/new' do
  @schedule = Schedule.new
  @form = schedules_form(@schedule)
  erb :"schedules/new"
end

get '/schedules/:id/delete' do
  @schedule = Schedule.find(params[:id])
  @schedule.destroy
  redirect to("#{ENV['BASE_URL']}/schedules")
end

get '/scheduleEvent/:id/delete' do
  @schedule_event = ScheduleEvent.find(params[:id])
  @schedule_event.destroy
end

get '/schedules/:id/edit' do
  @schedule = Schedule.find(params[:id])
  @form = schedules_form(@schedule)
  erb :"schedules/edit"
end

patch '/schedules/:id' do
  schedule = Schedule.find(params[:id])
  schedule.update(params[:schedule])
  schedule_events_params = params[:schedule_events]
  schedule_events_params.each do |key,se|
    next if key == "-1"
    schedule_event = nil
    if (key[0..("new_".length())])
      schedule.schedule_events.create(se)
    else
      schedule_event = ScheduleEvent.find(key)
      schedule_event.update(se)
    end

  end
  redirect to("#{ENV['BASE_URL']}/schedules")
end

post '/schedules' do
  schedule_params = params[:schedule]
  schedule_events_params = params[:schedule_events]
  schedule = Schedule.create!(schedule_params)
  schedule_events_params.each do |key,se|
    next if key == "-1"
    schedule.schedule_events.create(se)
  end
  redirect to("#{ENV['BASE_URL']}/schedules")
end

post '/schedules/activate' do
  device = Device.find(params[:device])
  schedule = Schedule.find(params[:schedule])
  ActiveSchedule.create!({
    device: device,
    schedule: schedule
  })
  redirect to("#{ENV['BASE_URL']}/schedules")
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
  @active_schedule = ActiveSchedule.find_by_device_id(@device.id) if @device

  if @device && @active_schedule
    @active_schedule = ActiveSchedule.find_by_device_id(@device.id)
    active_plugins = @active_schedule.schedule.get_active_plugins
    plugin_name = nil
    if active_plugins.is_a?(String)
      plugin_name = active_plugins
    else
      current_index = active_plugins.index(@active_schedule.last_shown_plugin) 
      next_index = current_index != nil ? current_index + 1 : 0
      plugin_name = active_plugins[next_index % active_plugins.length]
    end
    @active_schedule.last_shown_plugin = plugin_name
    @active_schedule.last_update = Time.now
    @active_schedule.save!
    screen = ScreenFetcher.generate_image_for_plugin(plugin_name)
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
  elsif @device
    screen = ScreenFetcher.empty_state_image
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
