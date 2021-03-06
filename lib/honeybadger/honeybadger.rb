require 'honeybadger'
require 'honeybadger/key_helpers'

module Honeybadger
  class << self
    def notify_detailed(error_class, error_message, parameters = {})
      # force class to be to string'd to prevent HB stackoverflow
      notify(error_class: error_class.to_s, error_message: error_message, parameters: parameters)
    end
    
    # detection of :alert_team option in errors from sidekiq workers
    def notify_or_ignore_with_devteam_detection(exception, options = {})
      alert_team = nil
      
      if options[:parameters]
        # allow strings or symbols. Not including active support for this
        if options[:parameters]['alert_team']
          alert_team = options[:parameters]['alert_team'].strip
        elsif options[:parameters][:alert_team]
          alert_team = options[:parameters][:alert_team].strip
        end
      end
      
      unless alert_team.nil? || alert_team.length == 0
        alert_team_key = KeyHelpers.env_key(alert_team)
        
        if ENV.has_key?(alert_team_key)
          options = options.merge({ api_key: ENV[alert_team_key] })
        end
      end

      notify_or_ignore_without_devteam_detection(exception, options)
    end

    alias_method :notify_or_ignore_without_devteam_detection, :notify_or_ignore
    alias_method :notify_or_ignore, :notify_or_ignore_with_devteam_detection
  end
end