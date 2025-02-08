require 'timecop'

require_relative 'spec_helper'

def create_basic_schedule()
  device = Device.create!({
    name: "Test Trmnl", 
    mac_address: 'aa:bb:cc:00:00:01',
  }) 
  schedule = Schedule.create!({
    name: "Test Basic Schedule",
    default_plugin: "plugin_a",
    schedule_events: [
      ScheduleEvent.create!({
        start_time: "00:00",
        end_time: "01:00",
        plugins: "plugin_se1_a,plugin_se1_b",
        update_frequency: 500,
      }),
      ScheduleEvent.create!({
        start_time: "01:00",
        end_time: "02:00",
        plugins: "plugin_se2_c,plugin_se2_d",
        update_frequency: 500,
      })
    ]
  })
  ActiveSchedule.create!({
    device: device,
    schedule: schedule,
  })
  return [device, schedule]
end

RSpec.describe 'schedule path tests' do
  it 'test_it_has_a_schedule_when_it_is_created' do
    _, sched = create_basic_schedule

    doc = get_and_parse '/schedules/'
    edit_anchor = doc.at(sprintf('a[href="/schedules/%d/edit"]', sched.id))

    expect(edit_anchor.text.strip).to eq("Edit")
  end
end

RSpec.describe 'image generation respects schedules' do
  before do
    @device, @schedule = create_basic_schedule
  end

  after do
    Timecop.return
  end

  it 'test_uses_default_plugin' do
    header("ACCESS_TOKEN", @device.api_key)
    twenty_two_thirty = Time.local(2013, 4, 5, 22, 30, 42)
    Timecop.freeze(twenty_two_thirty)

    _, body = get_json '/api/display/'

    expect(body['image_url']).to eq(ENV['BASE_URL'] + '/images/plugins/plugin_a/filename.bmp')

    @active_schedule = ActiveSchedule.find_by_device_id(@device.id)
    expect(@active_schedule.last_shown_plugin).to eq('plugin_a')
    expect(@active_schedule.last_update).to eq(twenty_two_thirty)
  end

  it 'test_uses_the_first_plugin_first' do
    header("ACCESS_TOKEN", @device.api_key)

    twelve_thirty_three = Time.local(2013, 4, 5, 0, 33, 42)
    Timecop.freeze(twelve_thirty_three)
    _, body = get_json '/api/display/'

    expect(body['image_url']).to eq(ENV['BASE_URL'] + '/images/plugins/plugin_se1_a/filename.bmp')

    @active_schedule = ActiveSchedule.find_by_device_id(@device.id)
    expect(@active_schedule.last_shown_plugin).to eq('plugin_se1_a')
    expect(@active_schedule.last_update).to eq(twelve_thirty_three)
  end

  it 'test_uses_the_second_plugin_second' do
    header("ACCESS_TOKEN", @device.api_key)

    twelve_thirty_three = Time.local(2013, 4, 5, 0, 33, 42)
    Timecop.freeze(twelve_thirty_three)
    _, body = get_json '/api/display/'

    Timecop.freeze(twelve_thirty_three + 100)
    _, body = get_json '/api/display/'

    expect(body['image_url']).to eq(ENV['BASE_URL'] + '/images/plugins/plugin_se1_b/filename.bmp')

    @active_schedule = ActiveSchedule.find_by_device_id(@device.id)
    expect(@active_schedule.last_shown_plugin).to eq('plugin_se1_b')
    expect(@active_schedule.last_update).to eq(twelve_thirty_three + 100)
  end

  it 'test_wraps_around_to_the_first_plugin' do
    header("ACCESS_TOKEN", @device.api_key)
    twelve_thirty_three = Time.local(2013, 4, 5, 0, 33, 42)
    Timecop.freeze(twelve_thirty_three)

    _, body = get_json '/api/display/'
    Timecop.freeze(twelve_thirty_three + 100)

    _, body = get_json '/api/display/'
    Timecop.freeze(twelve_thirty_three + 100 * 2)

    _, body = get_json '/api/display/'

    expect(body['image_url']).to eq(ENV['BASE_URL'] + '/images/plugins/plugin_se1_a/filename.bmp')

    @active_schedule = ActiveSchedule.find_by_device_id(@device.id)
    expect(@active_schedule.last_shown_plugin).to eq('plugin_se1_a')
    expect(@active_schedule.last_update).to eq(twelve_thirty_three + 100 * 2)
  end

  it 'test_can_find_the_correct_active_schedule_segment' do
    header("ACCESS_TOKEN", @device.api_key)

    one_thirty_three = Time.local(2013, 4, 5, 1, 33, 42)
    Timecop.freeze(one_thirty_three)
    _, body = get_json '/api/display/'

    expect(body['image_url']).to eq(ENV['BASE_URL'] + '/images/plugins/plugin_se2_c/filename.bmp')

    @active_schedule = ActiveSchedule.find_by_device_id(@device.id)
    expect(@active_schedule.last_shown_plugin).to eq('plugin_se2_c')
    expect(@active_schedule.last_update).to eq(one_thirty_three)
  end
end