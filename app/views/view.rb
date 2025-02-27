# frozen_string_literal: true

require "hanami/view"

module Views
  # The base view.
  class View < Hanami::View
    config.part_namespace = Parts
    config.paths = Bundler.root.join "app/templates"
    config.layout = "application"
  end
end
