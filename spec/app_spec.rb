# frozen_string_literal: true

require_relative "sinatra_helper"

RSpec.describe "Routes", type: :feature do
  subject(:app) { TRMNL::Application }

  describe ".loader" do
    it "eager loads" do
      expectation = proc { app.loader.eager_load force: true }
      expect(&expectation).not_to raise_error
    end

    it "answers unique tag" do
      expect(app.loader.tag).to eq("trmnl-application")
    end
  end

  it "visits root and instructs how to setup device" do
    visit "/"
    expect(page).to have_content("To set up your device")
  end

  it "displays add new device link" do
    visit "/devices"
    expect(page).to have_link("Add New")
  end
end
