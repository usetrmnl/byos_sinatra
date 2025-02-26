# frozen_string_literal: true

require "hanami/view"

module Views
  module Devices
    # The new view.
    class New < View
      config.template = "devices/new"

      expose :device
    end
  end
end
