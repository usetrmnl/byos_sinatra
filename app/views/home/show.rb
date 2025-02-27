# frozen_string_literal: true

require "hanami/view"

module Views
  module Home
    # The show view.
    class Show < View
      config.template = "home/show"
    end
  end
end
