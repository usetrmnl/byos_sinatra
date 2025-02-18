# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe 'Display path tests' do
  it 'test_it_has_api_display_path' do
    doc, body = get_json '/api/display/'
    expect(doc.status).to eq(404)
    expect(body['status']).to eq(404)
  end

  it 'test_it_has_a_display_path_with_a_device' do
    dev = Device.create!({
                           name: 'Test Trmnl',
                           mac_address: 'aa:ab:ac:00:00:01',
                           adopted: true
                         })
    header('ACCESS_TOKEN', dev.api_key)
    _, body = get_json '/api/display/'
    expect(body['reset_firmware']).to eq(false)
  end

  # requries having a last image to display
  it 'test_it_has_a_base64_display_path_with_a_device_in_the_query_params' do
    allow(ScreenFetcher).to receive(:find_last_updated_file).and_return('1as4ff.bmp')
    allow(File).to receive_message_chain(:open, :read).and_return('_1as4ff_bmp_data')

    dev = Device.create!({
                           name: 'Test Trmnl',
                           mac_address: 'aa:ab:ac:00:00:01',
                           adopted: true
                         })

    header('ACCESS_TOKEN', dev.api_key)
    _, body = get_json '/api/display/?base64=true'
    expect(body['image_url']).to include('data:image/png;base64')
  end

  # requries having a last image to display
  it 'test_it_has_a_base64_display_path_with_a_device_in_the_headers' do
    allow(ScreenFetcher).to receive(:find_last_updated_file).and_return('1as4ff.bmp')
    allow(File).to receive_message_chain(:open, :read).and_return('_1as4ff_bmp_data')

    dev = Device.create!({
                           name: 'Test Trmnl',
                           mac_address: 'aa:ab:ac:00:00:01',
                           adopted: true
                         })

    header('ACCESS_TOKEN', dev.api_key)
    header('BASE64', 'true')
    _, body = get_json '/api/display/'
    expect(body['image_url']).to include('data:image/png;base64')
  end
end
