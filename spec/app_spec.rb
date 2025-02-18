# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe "App base path tests", type: :feature do
  it "test_it_has_root_path" do
    browser = get "/"
    expect(browser.status).to be(200)
    expect(browser.body).to match("To set up your device")
  end

  it "test_it_has_device_list_path" do
    doc = get_and_parse "/devices"
    expect(doc.at('a[href="/devices/new"]').text.strip).to eq("Add New")
  end
end

RSpec.describe "API path tests", type: :feature do
  it "test_it_has_api_setup_path" do
    _, body = get_json "/api/setup/"
    expect(body["message"]).to eq("MAC Address not registered")
  end

  it "test_it_has_api_setup_path_with_a_device" do
    mac = "aa:bb:cc:00:00:01"
    dev = Device.create!({name: "Test Trmnl", mac_address: mac})
    header "ID", mac
    _, body = get_json "/api/setup/"
    expect(body["api_key"]).to eq(dev.api_key)
    expect(body["friendly_id"]).to eq(dev.friendly_id)
    expect(body["image_url"]).to eq("#{ENV["BASE_URL"]}/images/setup/setup-logo.bmp")
    expect(body["message"]).to eq("Welcome to TRMNL BYOS")
  end
end

RSpec.describe "Display path tests", type: :feature do
  it "test_it_has_api_setup_path" do
    _, body = get_json "/api/setup/"
    expect(body["message"]).to eq("MAC Address not registered")
  end

  it "test_it_has_api_setup_path_with_a_device" do
    mac = "aa:bb:cc:00:00:01"
    dev = Device.create!({name: "Test Trmnl", mac_address: mac})
    header "ID", mac
    _, body = get_json "/api/setup/"
    expect(body["api_key"]).to eq(dev.api_key)
    expect(body["friendly_id"]).to eq(dev.friendly_id)
    expect(body["image_url"]).to eq("#{ENV["BASE_URL"]}/images/setup/setup-logo.bmp")
    expect(body["message"]).to eq("Welcome to TRMNL BYOS")
  end
end
