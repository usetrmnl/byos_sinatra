class CreateDevices < ActiveRecord::Migration[8.0]
  def change
    create_table :devices do |t|
      t.string :name
      t.string :mac_address
      t.string :api_key
      t.string :friendly_id
      t.integer :refresh_interval, default: 900, null: false
      t.timestamps null: false
    end
  end
end
