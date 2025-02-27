# frozen_string_literal: true

class CreateDevices < ActiveRecord::Migration[8.0]
  def change
    create_table :devices do |table|
      table.string :name
      table.string :mac_address
      table.string :api_key
      table.string :friendly_id
      table.integer :refresh_interval, default: 900, null: false
      table.timestamps null: false
    end
  end
end
