# frozen_string_literal: true

require_relative "sinatra_helper"

RSpec.describe "Routes", type: :feature do
  it "visits root and instructs how to setup device" do
    visit "/"
    expect(page).to have_content("To set up your device")
  end

  it "displays add new device link" do
    visit "/devices"
    expect(page).to have_link("Add New")
  end
end
