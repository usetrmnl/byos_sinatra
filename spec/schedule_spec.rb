# frozen_string_literal: true

require 'timecop'

require_relative 'spec_helper'
require_relative '../services/screen_fetcher'

RSpec.describe 'schedule path tests' do
  it 'test_it_has_a_schedule_when_it_is_created' do
    _, sched = create_basic_schedule

    doc = get_and_parse '/schedules/'
    edit_anchor = doc.at(format('a[href="http://baseurl/schedules/%d/edit"]', sched.id))

    expect(edit_anchor.text.strip).to eq('Edit')
  end
end

RSpec.describe 'image generation respects schedules' do # rubocop:disable Metrics/BlockLength
  tmpdir = nil

  before do
    @device, @schedule = create_basic_schedule

    allow(ScreenFetcher)
      .to receive(:load_plugin)
      .and_return(true)

    tmpdir = Dir.mktmpdir

    allow(ScreenGenerator).to receive(:new)
      .and_return(instance_double('ScreenGenerator',
                                  process: true,
                                  img_filename: 'testfile.bmp'))
  end

  after do
    Timecop.return
    FileUtils.remove_entry tmpdir
  end

  it 'test_uses_default_plugin' do
    header('ACCESS_TOKEN', @device.api_key)
    twenty_two_thirty = Time.local(2013, 4, 5, 22, 30, 42)
    Timecop.freeze(twenty_two_thirty)

    _, body = get_json '/api/display/'

    expect(body['image_url']).to eq("#{ENV['BASE_URL']}/images/generated/plugin_a/testfile.bmp")

    @active_schedule = ActiveSchedule.find_by_device_id(@device.id)
    expect(@active_schedule.last_shown_plugin).to eq('plugin_a')
    expect(@active_schedule.last_update).to eq(twenty_two_thirty)
  end

  it 'test_uses_the_first_plugin_first' do
    header('ACCESS_TOKEN', @device.api_key)

    twelve_thirty_three = Time.local(2013, 4, 5, 0, 33, 42)
    Timecop.freeze(twelve_thirty_three)
    _, body = get_json '/api/display/'

    expect(body['image_url']).to eq("#{ENV['BASE_URL']}/images/generated/plugin_se1_a/testfile.bmp")

    @active_schedule = ActiveSchedule.find_by_device_id(@device.id)
    expect(@active_schedule.last_shown_plugin).to eq('plugin_se1_a')
    expect(@active_schedule.last_update).to eq(twelve_thirty_three)
  end

  it 'test_uses_the_second_plugin_second' do
    header('ACCESS_TOKEN', @device.api_key)

    twelve_thirty_three = Time.local(2013, 4, 5, 0, 33, 42)
    Timecop.freeze(twelve_thirty_three)
    get_json '/api/display/'

    Timecop.freeze(twelve_thirty_three + 100)
    _, body = get_json '/api/display/'

    expect(body['image_url']).to eq("#{ENV['BASE_URL']}/images/generated/plugin_se1_b/testfile.bmp")

    @active_schedule = ActiveSchedule.find_by_device_id(@device.id)
    expect(@active_schedule.last_shown_plugin).to eq('plugin_se1_b')
    expect(@active_schedule.last_update).to eq(twelve_thirty_three + 100)
  end

  it 'test_wraps_around_to_the_first_plugin' do
    header('ACCESS_TOKEN', @device.api_key)
    twelve_thirty_three = Time.local(2013, 4, 5, 0, 33, 42)
    Timecop.freeze(twelve_thirty_three)

    _doc, _body = get_json '/api/display/'
    Timecop.freeze(twelve_thirty_three + 100)

    _doc, _body = get_json '/api/display/'
    Timecop.freeze(twelve_thirty_three + 100 * 2)

    _, body = get_json '/api/display/'

    expect(body['image_url']).to eq("#{ENV['BASE_URL']}/images/generated/plugin_se1_a/testfile.bmp")

    @active_schedule = ActiveSchedule.find_by_device_id(@device.id)
    expect(@active_schedule.last_shown_plugin).to eq('plugin_se1_a')
    expect(@active_schedule.last_update).to eq(twelve_thirty_three + 100 * 2)
  end

  it 'test_can_find_the_correct_active_schedule_segment' do
    header('ACCESS_TOKEN', @device.api_key)

    one_thirty_three = Time.local(2013, 4, 5, 1, 33, 42)
    Timecop.freeze(one_thirty_three)
    _, body = get_json '/api/display/'

    expect(body['image_url']).to eq("#{ENV['BASE_URL']}/images/generated/plugin_se2_c/testfile.bmp")

    @active_schedule = ActiveSchedule.find_by_device_id(@device.id)
    expect(@active_schedule.last_shown_plugin).to eq('plugin_se2_c')
    expect(@active_schedule.last_update).to eq(one_thirty_three)
  end
end
