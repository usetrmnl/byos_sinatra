# frozen_string_literal: true

require "spec_helper"

RSpec.describe Images::Screensaver do
  subject(:screensaver) { described_class.new }

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

    let(:path) { temp_dir.join "test.jpeg" }

    it "creates screenshot" do
      screensaver.call content, path
      expect(path.exist?).to be(true)
    end

    it "answers image path" do
      expect(screensaver.call(content, path)).to be(path)
    end
  end
end
