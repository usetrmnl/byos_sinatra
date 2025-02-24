# frozen_string_literal: true

require "spec_helper"

RSpec.describe Images::Creator do
  subject(:creator) { described_class.new }

  include_context "with temporary directory"

  describe "#call" do
    let :content do
      <<~CONTENT
        <html>
          <head>
            <style>
              color: black;
              background-color: black;
            </style>
          </head>

          <body>
            <h1>Test</h1>
          </body>
        </html>
      CONTENT
    end

    let(:path) { temp_dir.join "test.bmp" }

    it "creates screenshot" do
      creator.call content, path
      image = MiniMagick::Image.open path

      expect(image).to have_attributes(
        dimensions: [800, 480],
        exif: {},
        type: "BMP3",
        data: hash_including("depth" => 1, "baseDepth" => 1)
      )
    end

    it "answers image path" do
      expect(creator.call(content, path)).to eq(path)
    end
  end
end
