require RAILS_ROOT + '/lib/color_logger'

module Rails
  @@import_log = nil

  def self.import_log
    if @@import_log.nil?
      @@import_log = ColorLogger.new(RAILS_ROOT + "/log/import_#{RAILS_ENV}.log")
      @@import_log.level = Logger::INFO # Optional, otherwise use the Rails defaults: development => DEBUG, production => INFO.
    end

    @@import_log
  end

end

class ActiveRecord::Base
  def import_log
    Rails.import_log
  end
end
