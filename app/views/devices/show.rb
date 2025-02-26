# frozen_string_literal: true

require "hanami/view"

module Views
  module Devices
    # The show view.
    class Show < View
      config.template = "devices/show"

      expose :device
    end
  end
end
