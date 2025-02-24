# frozen_string_literal: true

require "sinatra_helper"

RSpec.describe "API setup path tests" do
  subject(:app) { TRMNL::Application }

  include_context "with API"

  it "answers not registered when MAC address is invalid" do
    get "/api/setup/"
    expect(payload[:message]).to eq("MAC Address not registered")
  end

  it "registers device" do
    mac = "aa:bb:cc:00:00:01"
    device = Device.create! name: "Test Trmnl", mac_address: mac

    header "ID", mac
    get "/api/setup/"

    expect(payload).to eq(
      status: 200,
      api_key: device.api_key,
      friendly_id: device.friendly_id,
      image_url: %(#{ENV.fetch "APP_URL"}/images/setup/setup-logo.bmp),
      message: "Welcome to TRMNL BYOS"
    )
  end
end
