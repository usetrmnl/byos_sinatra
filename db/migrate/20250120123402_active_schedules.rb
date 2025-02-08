class ActiveSchedules < ActiveRecord::Migration[8.0]
  def change
    create_table :active_schedules do |t|
      t.belongs_to :device,        foreign_key: true, null: false 
      t.belongs_to :schedule,        foreign_key: true, null: false

      t.string :last_shown_plugin, default: "", null: true
      t.datetime :last_update, null: true

      t.timestamps null: false
    end
  end
end
