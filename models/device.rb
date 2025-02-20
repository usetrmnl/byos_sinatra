# frozen_string_literal: true

# The device model.
class Device < ActiveRecord::Base
  DEFAULT_DEVICE_NAME = "My TRMNL"
  MODEL = [{name: "og", width: 800, height: 480, color_depth: 1}].freeze

  attribute :name, default: DEFAULT_DEVICE_NAME
  validates :name, :mac_address, presence: true
  before_create :generate_friendly_id, :generate_api_key

  def generate_friendly_id
    self.friendly_id = SecureRandom.hex(3).upcase
  end

  def generate_api_key
    self.api_key = SecureRandom.urlsafe_base64 nil, false
  end
end
