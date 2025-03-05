# frozen_string_literal: true

require "sinatra_helper"

RSpec.describe "Images" do
  subject(:app) { TRMNL::Application }

  include_context "with API"

  let(:path) { Bundler.root.join "public/images/generated/rspec_test.bmp" }
  let(:body) { {image: {content: "<p>Test</p>", file_name: "rspec_test"}} }

  after { path.delete }

  it "creates image" do
    post "/api/images", body.to_json, format: :json
    expect(Pathname(payload[:path]).exist?).to be(true)
  end

  it "answers path" do
    post "/api/images", body.to_json, format: :json
    expect(payload[:path]).to eq(path.to_s)
  end
end
