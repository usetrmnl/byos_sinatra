class UnregisteredDevices < ActiveRecord::Migration[8.0]
  def change
    add_column :devices, :adopted, :boolean, default: false, null: false

    create_table :ignored_macs do |t|
      t.string :mac_address

      t.timestamps null: false
    end
  end
end
