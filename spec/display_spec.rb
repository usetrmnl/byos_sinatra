# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'Display path tests' do
  it 'test_it_has_api_display_path' do
    _, body = get_json '/api/display/'
    expect(body['status']).to eq(404)
  end

  it 'test_it_has_a_display_path_with_a_device' do
    dev = Device.create!({
                           name: 'Test Trmnl', mac_address: 'aa:ab:ac:00:00:01'
                         })
    header('ACCESS_TOKEN', dev.api_key)
    _, body = get_json '/api/display/'
    expect(body['image_url']).to eq('http://baseurl/images/setup/setup-logo.bmp')
    expect(body['reset_firmware']).to eq(false)
  end

  it 'test_it_has_a_base64_display_path_with_a_device' do
    dev = Device.create!({
                           name: 'Test Trmnl', mac_address: 'aa:ab:ac:00:00:01'
                         })

    header('ACCESS_TOKEN', dev.api_key)
    _, body = get_json '/api/display/?base64=true'
    expect(body['image_url']).to include('data:image/png;base64')

    header('BASE64', 'true')
    _, body = get_json '/api/display/'
    expect(body['image_url']).to include('data:image/png;base64')
  end
end
