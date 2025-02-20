# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe "Routes", type: :feature do
  it "visits root and instructs how to setup device" do
    response = get "/"
    expect(response.body).to match("To set up your device")
  end

  it "displays add new device link" do
    response = get "/devices"
    expect(response.body).to match(%r(<a href=".+/devices/new".+Add New.+</a>)m)
  end

  it "doesn't register device with invalid MAC address" do
    payload = get_json "/api/setup/"
    expect(payload[:message]).to eq("MAC Address not registered")
  end

  it "registers device" do
    mac = "aa:bb:cc:00:00:01"
    device = Device.create! name: "Test Trmnl", mac_address: mac

    header "ID", mac
    payload = get_json "/api/setup/"

    expect(payload).to eq(
      status: 200,
      api_key: device.api_key,
      friendly_id: device.friendly_id,
      image_url: %(#{ENV.fetch "BASE_URL"}/images/setup/setup-logo.bmp),
      message: "Welcome to TRMNL BYOS"
    )
  end
end
