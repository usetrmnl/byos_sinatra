# frozen_string_literal: true

require "securerandom"

module Images
  Randomizer = proc { SecureRandom.uuid }
end
