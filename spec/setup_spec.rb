# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe "API setup path tests" do
  it "test_it_has_api_setup_path" do
    _, body = get_json "/api/setup/"
    expect(body["message"]).to eq("MAC Address not registered")
  end

  it "test_it_has_api_setup_path_with_a_device" do
    mac = "aa:bb:cc:00:00:01"
    dev = Device.create!({ name: "Test Trmnl", mac_address: mac })
    header("ID", mac)
    _, body = get_json "/api/setup/"
    expect(body["api_key"]).to eq(dev.api_key)
    expect(body["friendly_id"]).to eq(dev.friendly_id)
    expect(body["image_url"]).to eq("#{ENV["BASE_URL"]}/images/setup/setup-logo.bmp")
    expect(body["message"]).to eq("Welcome to TRMNL BYOS")
  end
end
