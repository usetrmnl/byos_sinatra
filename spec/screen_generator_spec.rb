# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'ScreenGenerator tests' do
  tmpdir = nil
  before(:each) do
    tmpdir = Dir.mktmpdir
  end

  after(:each) do
    FileUtils.remove_entry tmpdir
  end

  it('it_does_not_create_a_file_if_process_was_not_called') do
    sg = ScreenGenerator.new('<div>Hello <i>world</i></div>', tmpdir)

    expect(sg).not_to be(nil)
    expect(File.exist?(sg.img_path)).to be(false)
  end

  it('it_creates_a_bmp') do
    sg = ScreenGenerator.new('<div>Hello <i>world</i></div>', tmpdir)
    sg.process

    expect(sg).not_to be(nil)
    expect(File.exist?(sg.img_path)).to be(true)
    bmp_magic_bytes = File.open(sg.img_path, 'r').read(2)
    expect(bmp_magic_bytes).to eq('BM')
  end
end
