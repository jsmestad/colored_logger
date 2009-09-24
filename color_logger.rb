require 'active_support'

class ColorLogger < ActiveSupport::BufferedLogger
  COLORS = {
    :nothing      => '0;0',
    :black        => '0;30',
    :red          => '0;31',
    :green        => '0;32',
    :brown        => '0;33',
    :blue         => '0;34',
    :cyan         => '0;36',
    :purple       => '0;35',
    :light_gray   => '0;37',
    :dark_gray    => '1;30',
    :light_red    => '1;31',
    :light_green  => '1;32',
    :yellow       => '0;33', # changed due to OSX not showing yellow to be yellow?
    :light_blue   => '1;34',
    :light_cyan   => '1;36',
    :light_purple => '1;35',
    :white        => '1;37',
  } unless defined?(COLORS)
  
  def color(key)
    COLORS.key?(key) ? "\033[#{COLORS[key]}m" : ""
  end
  
  private

    # Define strings for log levels
    def severity_string(level)
      if ActiveRecord::Base.colorize_logging
        case level
        when DEBUG; "#{color(:light_green)}DEBUG"
        when INFO;  "#{color(:green)}INFO"
        when WARN;  "#{color(:yellow)}WARN"
        when ERROR; "#{color(:light_red)}ERROR"
        when FATAL; "#{color(:red)}FATAL"
        else
            "#{color(:purple)}UNKNOWN"
        end
      else
        case level
        when DEBUG; :DEBUG
        when INFO; :INFO
        when WARN; :WARN
        when ERROR; :ERROR
        when FATAL; :FATAL
        else
            :UNKNOWN
        end
      end
    end
    
    def output_message(level, message)
      if ActiveRecord::Base.colorize_logging
        case level
        when DEBUG; "#{color(:light_green)}#{message}"
        when INFO; "#{color(:black)}#{message}"
        else
          "#{color(:white)}#{message}"
        end
      else
        "#{message}"
      end
    end

  public

    # monkey patch the logger add method so that
    # we can format the log messages the way we want (with color!)
    def add(severity, message = nil, progname = nil, &block)
      return if @level > severity
      message = (message || (block && block.call) || progname).to_s
      # If a newline is necessary then create a new message ending with a newline.
      # Ensures that the original message is not mutated.
      if ActiveRecord::Base.colorize_logging
        message = "#{color(:black)}[%5s #{color(:dark_gray)}%s#{color(:black)}] #{color(:black)}[#{color(:brown)}%s#{color(:black)}.#{color(:blue)}%s#{color(:black)}]#{color(:nothing)} %s\n" % [severity_string(severity),
                                             Time.now.strftime("%m/%d/%y %H:%M:%S"),
                                             $0, $$,
                                             output_message(severity,message)] unless message[-1] == ?\n
      else
        message = "[%5s %s] [%s.%s] %s\n" % [severity_string(severity),
                                             Time.now.strftime("%m/%d/%y %H:%M:%S"),
                                             $0,  $$,
                                             message] unless message[-1] == ?\n
      end
      buffer << message
      auto_flush
      message
    end

end

