require_relative 'spec_helper'

RSpec.describe 'App base path tests' do
  it 'test_it_has_root_path' do
    browser = get '/'
    expect(browser.status).to be(200)
    expect(browser.body).to match("To set up your device")
  end

  it 'test_it_has_root_path' do
    browser = get '/'
    expect(browser.status).to be(200)
    expect(browser.body).to match("To set up your device")
  end
end