require 'dotenv'
require 'erb'
require 'yaml'
require 'json'
require 'uri'

module BikeIn
  module Common

    class CustomConfiguration

      def initialize
        Dotenv.load("#{File.dirname(__FILE__)}/../.env")
        env = ENV['BOT_ENV'] || 'development'
        @config = JSON.parse(
            JSON.dump(YAML.load( ERB.new(File.open("#{File.dirname(__FILE__)}/../config/settings.yml").read).result )[env]),
            symbolize_names: true
        )
        check_config
      end
      def [](index)
        @config[index.to_sym]
      end
      def []=(index,value)
       @config[index.to_sym] = value
      end
      def append(more_config)
        @config.merge!(more_config)
      end
      def logs
        [
          @config[:logs][:stdout_enable],
          @config[:logs][:stdout_level],
          @config[:logs][:syslog_enable],
          @config[:logs][:syslog_level]
        ]
      end
      def disable_logs!
        # in test I dont want message out rspec
        @config[:logs][:stdout_enable] = false
        @config[:logs][:syslog_enable] = false
      end
      def enable_stdout_logs!
        # in test I dont want message out rspec
        @config[:logs][:stdout_enable] = true
        @config[:logs][:syslog_enable] = false
      end


      def fiware_service_enable?
        @config[:context_broker][:header_service_enable]
      end
      def fiware_service
        @config[:context_broker][:header_service] if @config[:context_broker][:header_service_enable]
      end

      def check_config
        # token and refresh token only can get first time through session http into marketplace
        # we should feed throught ENVIRONMENT variables first time and renew from now on

        # TODO CHECK SOURCES REPO ...

        # TODO CHECK DESTINATION REPO ...

      end

    end # class

  end
end
