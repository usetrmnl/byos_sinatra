require_relative 'spec_helper'

def adopted_device
  Device.create({
                  name: "Leonardo's TRML",
                  mac_address: 'A0:AA:AB:00:01:01',
                  adopted: true
                })
end

def unadopted_device
  UnadoptedDevice.create({
                           name: "Bebop's TRML",
                           mac_address: 'A0:AA:AB:00:02:02',
                           adopted: false
                         })
end

RSpec.describe 'Device tests' do
  it 'adopted_devices_are_listed' do
    device = adopted_device

    expect(Device.all).to eq([device])
    expect(UnadoptedDevice.all).to eq([])
  end

  it 'unadopted_devices_are_not_listed' do
    device = unadopted_device

    expect(Device.all).to eq([])
    expect(UnadoptedDevice.all).to eq([device])
  end

  it 'unadopted_devices_are_listed_on_the_index_page' do
    device = unadopted_device

    doc = get_and_parse '/'
    expect(doc.at('li[@class="adoptable"]').text).to include(device.mac_address)
  end

  it 'adopted_devices_are_not_listed_on_the_index_page' do
    adopted = adopted_device
    unadopted_device

    doc = get_and_parse '/'
    expect(doc.search('li').length).to be(1)
    expect(doc.at('li[@class="adoptable"]').text).not_to include(adopted.mac_address)
  end

  it 'ignored_macs_are_not_listed_and_do_not_reappear' do
    device = unadopted_device
    get "/setup/ignore/#{device.id}"

    doc = get_and_parse '/'
    expect(doc.search('li').length).to be(0)
  end
end
