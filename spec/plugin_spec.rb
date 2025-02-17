# frozen_string_literal: true

require_relative 'spec_helper'

module Plugins
  class PluginA < Base
    def locals
      { settingA: settingA }
    end

    def settingA # rubocop:disable Naming/MethodName
      'settingA'
    end
  end
end

RSpec.describe 'Plugin tests' do
  tmpdir = nil
  before(:each) do
    @device, @schedule = create_simple_schedule

    allow(ScreenFetcher)
      .to receive(:require_relative)
      .and_return(true)

    tmpdir = Dir.mktmpdir

    allow(ScreenGenerator).to receive(:new)
      .and_return(instance_double('ScreenGenerator',
                                  process: true,
                                  img_filename: 'testfile.bmp'))
  end

  after(:each) do
    FileUtils.remove_entry tmpdir
  end

  it 'can_load_a_plugin' do
    header('ACCESS_TOKEN', @device.api_key)
    _, body = get_json '/api/display/'

    expect(body['image_url']).to eq("#{ENV['BASE_URL']}/images/generated/plugin_a/testfile.bmp")
  end
end
