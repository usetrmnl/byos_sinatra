# frozen_string_literal: true

# Ensures a mac address passed as a string is valid
class MacValidation
  def self.valid?(mac_address)
    mac_address&.match(mac_regex) != nil
  end

  def self.mac_regex
    /\A[A-Fa-f0-9][048Cc26AaEe][-:]([A-Fa-f0-9]{2}[-:]){4}[A-Fa-f0-9]{2}\z/
  end
end
