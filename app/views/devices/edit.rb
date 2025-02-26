# frozen_string_literal: true

require "hanami/view"

module Views
  module Devices
    # The edit view.
    class Edit < View
      config.template = "devices/edit"

      expose :device
    end
  end
end
