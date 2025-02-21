# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe "Routes", type: :feature do
  it "visits root and instructs how to setup device" do
    response = get "/"
    expect(response.body).to match("To set up your device")
  end

  it "test_it_has_device_list_path" do
    doc = get_and_parse "/devices"
    expect(doc.at('a[href="http://baseurl/devices/new"]').text.strip).to eq("Add New")
  end
end
