class ActiveSchedule < ActiveRecord::Base
  belongs_to :device
  belongs_to :schedule

  validates :device_id, presence: true
  validates :schedule_id, presence: true
end