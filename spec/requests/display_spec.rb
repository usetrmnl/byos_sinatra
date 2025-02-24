# frozen_string_literal: true

require "sinatra_helper"

RSpec.describe "Display path tests" do
  subject(:app) { TRMNL::Application }

  include_context "with API"

  it "answers not found for index with invalid access token" do
    get "/api/display/", format: :json
    expect(payload[:status]).to eq(404)
  end

  it "answers devices with valid access token" do
    device = Device.create! name: "Test Trmnl", mac_address: "aa:ab:ac:00:00:01"
    header "ACCESS_TOKEN", device.api_key
    get "/api/display/"
    expect(payload[:reset_firmware]).to be(false)
  end

  it "answers image URL base 64 header" do
    pending "Needs to be fixed"

    header "BASE64", "true"
    get "/api/display/"
    expect(payload[:image_url]).to include("data:image/png;base64")
  end

  it "answers image URL with base 64 parameter" do
    pending "Needs to be fixed"

    device = Device.create! name: "Test Trmnl", mac_address: "aa:ab:ac:00:00:01"

    header "ACCESS_TOKEN", device.api_key
    get "/api/display/?base64=true"
    expect(payload[:image_url]).to include("data:image/png;base64")
  end
end
