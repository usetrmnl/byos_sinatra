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
    fill_in "Name", with: "Test New"
    fill_in "MAC", with: "aa:bb:cc:01:02:03"
    fill_in "Refresh Rate", with: 100
    click_on "Save"

    expect(page).to have_content(/Test New.+aa:bb:cc:01:02:03.+100/)
  end

  it "shows device" do
    device
    visit "/devices/#{device.id}"

    expect(page).to have_content(device.name)
  end

  it "edits device" do
    device
    visit "/devices"
    click_on "Edit"
    fill_in "Name", with: "Test Edit"
    fill_in "MAC", with: "aa:aa:aa:00:00:00"
    fill_in "Refresh Rate", with: 123
    click_on "Save"

    expect(page).to have_content(/Test Edit.+aa:aa:aa:00:00:00.+123/)
  end

  it "deletes device" do
    pending "The database connection needs to be established first."

    device
    visit "/devices"
    click_on "Delete"

    expect(page).to have_no_content("New")
  end

  it "visits home page" do
    visit "/devices"
    click_on "Home"

    expect(page).to have_content("Welcome")
  end
end
