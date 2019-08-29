require 'logger'
require 'syslog/logger'

module BikeIn
  module Common

    class CustomLogger
      def initialize(instance)
        @env = ENV['BOT_ENV']
        @instance = instance
        @logger = Logger.new STDOUT
        @logger_file = Logger.new($config[:logs][:filename])
        @syslog = Syslog.instance || Syslog.open(instance, Syslog::LOG_PID, Syslog::LOG_DAEMON | Syslog::LOG_LOCAL3)
      end
      def decorator(msg)
        "(#{@env}) #{@instance}: #{msg}"
      end
      def level(new_level)
        @logger.level(new_level.upcase!) if $config[:logs][:stdout_enable]
        @logger_file.level(new_level.upcase!) if $config[:logs][:stdout_enable]
        @syslog.level(new_level.upcase!) if $config[:logs][:syslog_enable]
      end
      def debug(msg)
        @logger.debug(decorator(msg)) if $config[:logs][:stdout_enable]
        @logger_file.debug(decorator(msg)) if $config[:logs][:stdout_enable]
        @syslog.log(Syslog::LOG_DEBUG, decorator(msg)) if $config[:logs][:syslog_enable]
      end
      def info(msg)
        @logger.info(decorator(msg)) if $config[:logs][:stdout_enable]
        @logger_file.info(decorator(msg)) if $config[:logs][:stdout_enable]
        @syslog.log(Syslog::LOG_INFO, decorator(msg)) if $config[:logs][:syslog_enable]
      end
      def warn(msg)
        @logger.warn(decorator(msg)) if $config[:logs][:stdout_enable]
        @logger_file.warn(decorator(msg)) if $config[:logs][:stdout_enable]
        @syslog.log(Syslog::LOG_WARNING, decorator(msg)) if $config[:logs][:syslog_enable]
      end
      def error(msg)
        @logger.error(decorator(msg)) if $config[:logs][:stdout_enable]
        @logger_file.error(decorator(msg)) if $config[:logs][:stdout_enable]
        @syslog.log(Syslog::LOG_ERR, decorator(msg)) if $config[:logs][:syslog_enable]
      end
    end

  end
end
