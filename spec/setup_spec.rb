# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe "API setup path tests", type: :feature do
  it "test_it_has_api_setup_path" do
    _, body = get_json "/api/setup/"
    expect(body["message"]).to eq("MAC Address not registered")
  end

  it 'test_it_will_not_add_invalid_macs_to_the_database' do
    invalid_mac = '01:00:00:00:00:00'
    header('ID', invalid_mac)
    get_json '/api/setup/'
    device = Device.find_by_mac_address(invalid_mac)
    expect(device).to be(nil)
  end

  it 'test_it_will_create_device_requiring_adoption' do
    mac = 'a0:Ab:cc:00:00:01'
    header('ID', mac)
    _, body = get_json '/api/setup/'
    expect(body['api_key']).to be(nil)
    expect(body['friendly_id']).to be(nil)
    expect(body['image_url']).to eq(ENV['BASE_URL'] + '/images/setup/setup-logo.bmp')
    expect(body['message']).to eq('Please adopt this device')
    device = Device.find_by_mac_address(mac)
    expect(device).to be_falsy
    unadopted_device = UnadoptedDevice.find_by_mac_address(mac)
    expect(unadopted_device).to be_truthy
    expect(unadopted_device.adopted).to be(false)
  end

  it 'it_wont_list_the_same_mac_for_adoption_multiple_times' do
    mac = 'a0:Ab:cc:00:00:01'
    header('ID', mac)

    get_json '/api/setup/'
    get_json '/api/setup/'

    unadopted_devices = UnadoptedDevice.all
    expect(unadopted_devices.length).to be(1)
  end

  it 'it_wont_add_ignored_macs_for_adoption' do
    mac = 'a0:Ab:cc:00:00:01'
    IgnoredMac.create!({ mac_address: mac })
    header('ID', mac)

    get_json '/api/setup/'

    unadopted_devices = UnadoptedDevice.all
    expect(unadopted_devices.length).to be(0)
  end

  it 'test_it_is_still_not_setup_until_it_is_adopted' do
    mac = 'a0:bb:cc:00:00:01'
    Device.create!({
                     name: 'Test Trmnl',
                     mac_address: mac,
                     adopted: false
                   })
    header('ID', mac)
    _, body = get_json '/api/setup/'
    expect(body['api_key']).to be(nil)
    expect(body['friendly_id']).to be(nil)
    expect(body['image_url']).to eq(ENV['BASE_URL'] + '/images/setup/setup-logo.bmp')
    expect(body['message']).to eq('Please adopt this device')
  end

  it 'test_it_has_api_setup_path_with_a_device' do
    mac = 'a0:bb:cc:00:00:01'
    dev = Device.create!({
                           name: 'Test Trmnl',
                           mac_address: mac,
                           adopted: true
                         })
    header('ID', mac)
    _, body = get_json '/api/setup/'
    expect(body['api_key']).to eq(dev.api_key)
    expect(body['friendly_id']).to eq(dev.friendly_id)
    expect(body['image_url']).to eq("#{ENV['BASE_URL']}/images/setup/setup-logo.bmp")
    expect(body['message']).to eq('Welcome to TRMNL BYOS')
  end
end
