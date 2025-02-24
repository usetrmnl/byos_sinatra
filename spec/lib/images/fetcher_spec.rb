# frozen_string_literal: true

require "spec_helper"

RSpec.describe Images::Fetcher do
  using Refinements::Pathname

  subject(:fetcher) { described_class.new environment: }

  include_context "with temporary directory"

  let(:environment) { {"APP_URL" => "https://test.io"} }

  describe "#call" do
    let(:fixture_path) { SPEC_ROOT.join "support/fixtures/test.bmp" }

    it "answers default image" do
      expect(fetcher.call).to eq(
        filename: "empty_state",
        image_url: "https://test.io/images/setup/setup-logo.bmp"
      )
    end

    it "answers generated image without encryption" do
      path = temp_dir.join("public/images/generated").mkpath.join("test.bmp")
      fixture_path.copy path

      expect(fetcher.call(path.parent)).to eq(
        filename: "test.bmp",
        image_url: "https://test.io/images/generated/test.bmp"
      )
    end

    it "answers generated image with encryption" do
      fetcher = described_class.new(encryption: :base_64, environment:)

      path = temp_dir.join("public/images/generated").mkpath.join("test.bmp")
      fixture_path.copy path

      expect(fetcher.call(path.parent)).to match(
        filename: "test.bmp",
        image_url: %r(data:image/bmp;base64,.+)
      )
    end

    it "answers generated image without encryption when given invalid encryption" do
      fetcher = described_class.new(encryption: :bogus, environment:)

      path = temp_dir.join("public/images/generated").mkpath.join("test.bmp")
      fixture_path.copy path

      expect(fetcher.call(path.parent)).to eq(
        filename: "test.bmp",
        image_url: "https://test.io/images/generated/test.bmp"
      )
    end
  end
end
