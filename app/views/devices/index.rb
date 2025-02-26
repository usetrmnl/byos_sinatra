# frozen_string_literal: true

require "hanami/view"

module Views
  module Devices
    # The index view.
    class Index < View
      config.template = "devices/index"

      expose :devices
    end
  end
end
