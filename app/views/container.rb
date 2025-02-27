# frozen_string_literal: true

require "containable"

module Views
  # Contains view related dependencies.
  module Container
    extend Containable

    namespace :devices do
      register(:edit) { Devices::Edit.new }
      register(:index) { Devices::Index.new }
      register(:new) { Devices::New.new }
      register(:show) { Devices::Show.new }
    end

    namespace :home do
      register(:show) { Home::Show.new }
    end
  end
end
