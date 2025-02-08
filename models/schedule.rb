class Schedule < ActiveRecord::Base
  has_many :schedule_events

  def get_active_plugins
    now = Time.now
    nowish = Time.new(2000, 1, 1, now.hour, now.min, now.sec)
    if self.schedule_events
      self.schedule_events.each do |se|
        if nowish > se.start_time && nowish < se.end_time
          return se.plugins.split(',')
        end
      end
    end
    self.default_plugin
  end
end