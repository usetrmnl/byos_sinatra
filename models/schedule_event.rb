class ScheduleEvent < ActiveRecord::Base
  belongs_to :schedules

  # Validations
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :interruptible, inclusion: { in: [true, false] }
  validates :update_frequency, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  validate :end_time_after_start_time
  validate :update_frequency_options

  # Custom validation to ensure end_time is after start_time
  def end_time_after_start_time
    binding.break
    if end_time <= start_time
      errors.add(:end_time, "must be after the start time")
    end
  end

  def update_frequency_options
    [15,30,45,60,120,240].include?(update_frequency)
  end

  # Helper to return plugins as an array
  def plugins_list
    plugins.split(',').map(&:strip)
  end

  # Helper to set plugins from an array
  def plugins_list=(list)
    self.plugins = list.join(',')
  end
end
