class CreateSchedule < ActiveRecord::Migration[8.0]
  def change
    create_table :schedule_events do |t|
      t.references :schedule,        foreign_key: true

      t.time :start_time, null: false
      t.time :end_time, null: false
      t.boolean :interruptible, default: false, null: false
      t.string :plugins, default: "", null: false
      t.integer :update_frequency, null: true

      t.timestamps null: false
    end

    create_table :schedules do |t|
      t.string :name, null: false

      t.string :default_plugin, default: ""

      t.timestamps null: false
    end
  end
end
