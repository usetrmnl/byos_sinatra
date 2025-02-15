require_relative 'spec_helper'

module Plugins
  class PluginA < Base
    def locals 
      { settingA: }
    end

    def settingA
      "settingA"
    end
  end
end

def mock_plugin_a
  allow(ScreenFetcher)
    .to receive(:require_relative)
    .and_return(true)
end

RSpec.describe 'Plugin tests' do
  before do
    @device, @schedule = create_simple_schedule
    mock_plugin_a
  end

  it ('can_load_a_plugin') do
    header("ACCESS_TOKEN", @device.api_key)
    _, body = get_json '/api/display/'

    expect(body['image_url']).to eq(ENV['BASE_URL'] + '/images/plugins/plugin_a/filename.bmp')
  end
end