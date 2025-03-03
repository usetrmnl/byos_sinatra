# frozen_string_literal: true

require "spec_helper"

RSpec.describe Images::Toucher do
  using Refinements::Pathname

  subject(:toucher) { described_class }

  include_context "with temporary directory"

  describe "#call" do
    let(:one) { temp_dir.join "one.png" }
    let(:two) { temp_dir.join "two.png" }
    let(:three) { temp_dir.join "three.png" }
    let(:all) { [one, two, three] }

    it "answers second file created as latest file" do
      skip "Doesn't work on CI." if ENV["CI"]

      all.each(&:touch)
      toucher.call temp_dir

      expect(all.sort_by(&:ctime)).to eq([two, three, one])
    end

    it "answers last file created as latest file" do
      skip "Doesn't work on CI." if ENV["CI"]

      all.each(&:touch)
      toucher.call temp_dir
      toucher.call temp_dir

      expect(all.sort_by(&:ctime)).to eq([three, one, two])
    end
  end
end
