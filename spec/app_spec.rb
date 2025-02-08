require_relative 'spec_helper'

RSpec.describe 'App base path tests' do
  it 'test_it_has_root_path' do
    browser = get '/'
    expect(browser.status).to be(200)
    expect(browser.body).to match("To set up your device")
  end

  it 'test_it_has_device_list_path' do
    doc = get_and_parse '/devices'
    expect(doc.at('a[href="http://baseurl/devices/new"]').text.strip).to eq('Add new device')
  end

  it 'test_it_has_device_list_path' do
    doc = get_and_parse '/schedules'
    expect(doc.at('a[href="http://baseurl/schedules/new"]').text.strip).to eq('Add new schedule')
  end
end