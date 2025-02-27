# frozen_string_literal: true

require "sinatra_helper"

RSpec.describe "Devices" do
  subject(:app) { TRMNL::Application }

  let(:device) { Device.create! name: "Test", mac_address: "aa:bb:cc:01:02:03" }

  it "displays index" do
    device
    visit "/devices"

    expect(page).to have_content(device.friendly_id)
  end

  it "creates device" do
    visit "/devices"
    click_on "New"
    fill_in "Name", with: "Test"
    fill_in "MAC", with: "aa:bb:cc:01:02:03"
    click_on "Save"

    device = Device.find_by name: "Test"

    expect(page).to have_content(device.friendly_id)
  end

  it "edits device" do
    device
    visit "/devices"
    click_on "Edit"
    fill_in "Name", with: "Test Edit"
    click_on "Save"

    expect(page).to have_content("Test Edit")
  end

  it "deletes device" do
    device
    visit "/devices"
    click_on "Delete"

    expect(page).to have_content("New")
  end

  it "visits home page" do
    visit "/devices"
    click_on "Home"

    expect(page).to have_content("Welcome")
  end
end
