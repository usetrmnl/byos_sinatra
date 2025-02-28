# frozen_string_literal: true

require "spec_helper"

RSpec.describe Images::Rotator do
  using Refinements::Pathname

  subject(:rotator) { described_class.new fetcher: Images::Fetcher.new(environment:) }

  include_context "with temporary directory"

  let(:environment) { {"APP_URL" => "https://test.io"} }

  describe "#call" do
    it "answers oldest image as newest image" do
      temp_dir.join("one.bmp").touch
      temp_dir.join("two.bmp").touch

      expect(rotator.call(temp_dir)).to eq(
        filename: "one.bmp",
        image_url: "https://test.io/images/generated/one.bmp"
      )
    end

    it "answers oldest image as newest image with encryption" do
      temp_dir.join("one.bmp").touch
      temp_dir.join("two.bmp").touch

      expect(rotator.call(temp_dir, encryption: :base_64)).to eq(
        filename: "one.bmp",
        image_url: "data:image/bmp;base64,"
      )
    end
  end
end
