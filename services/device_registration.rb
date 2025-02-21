# frozen_string_literal: true

# Determines if a device is new, and shoudl be placed pending adoption
# has been adopted, in which case it should just show a welcome screen
# or is a device that is not valid or is ignored
class DeviceRegistration
  class << self
    def call(mac_address)
      device = Device.find_by_mac_address(mac_address)

      return adopted_status_details(device) if device_adopted?(device)

      return unadopted_status_details('MAC Address not registered') if mac_is_invalid_or_ignored(mac_address)

      create_device_pending_adoption(mac_address) if device_has_not_been_seen(mac_address)

      unadopted_status_details('Please adopt this device')
    end

    def device_adopted?(device)
      device&.adopted
    end

    def mac_is_invalid_or_ignored(mac_address)
      !MacValidation.valid?(mac_address) || ignored_mac?(mac_address)
    end

    def device_has_not_been_seen(mac_address)
      @unadopted_device = UnadoptedDevice.find_by_mac_address(mac_address)
      @unadopted_device.nil? && MacValidation.valid?(mac_address) && !ignored_mac?(mac_address)
    end

    def adopted_status_details(device)
      {
        api_status: 200,
        api_key: device.api_key,
        friendly_id: device.friendly_id,
        image_url: "#{ENV['BASE_URL']}/images/setup/setup-logo.bmp",
        message: 'Welcome to TRMNL BYOS'
      }
    end

    def unadopted_status_details(message)
      {
        api_status: 404,
        api_key: nil,
        friendly_id: nil,
        image_url: setup_logo,
        message: message
      }
    end

    def create_device_pending_adoption(mac_address)
      Device.create!({
                       name: "Device #{mac_address}",
                       mac_address: mac_address,
                       api_key: '',
                       friendly_id: nil,
                       adopted: false
                     })
    end

    def ignored_mac?(mac_address)
      ignored_macs = IgnoredMac.find_by_mac_address(mac_address)
      !ignored_macs.nil?
    end

    def setup_logo
      "#{ENV['BASE_URL']}/images/setup/setup-logo.bmp"
    end
  end
end
