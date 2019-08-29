require 'net/http'
require_relative 'custom_configuration'
require_relative 'custom_logger'


module Network

    class Backoff
      RETR = 5

      def initialize(uri, &blk)
        @retries = RETR
        @uri = uri.to_s
        @cmd = blk
        @log = BikeIn::Common::CustomLogger.new self.to_s
      end

      def run!
        begin
          @cmd.call
        rescue SystemCallError => ex
          @log.error "Caught #{ex.class}: #{ex.message}\nPlease check your host/port is reachable: #{@uri}"
        rescue StandardError => ex
          if @retries > 0
            @log.warn "Caught #{ex.class}: #{ex.message} while talking to #{@uri} - Retrying... #{current_retry} / #{RETR}"
            backoff!
            @retries -= 1
            retry
          else
            @log.error "#{@uri} not responding after #{RETR} retries!  Giving up!"
          end
        end
      end

      def current_retry
        RETR - @retries + 1
      end

      private
      def backoff!
        nap = (2**@retries - 1) / 2
        @log.info "sleeping for #{nap} seconds"
        Thread.current.send(:sleep, nap)
      end
    end

    module SafeNetHTTP
      def self.start(uri, opts, &blk)
        (Backoff.new(uri) do
          Net::HTTP.start(uri.host, uri.port, opts){ |handler| yield handler }
        end).run!
      end
    end

end
