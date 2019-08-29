require 'net/http'
# require_relative "http_response"
# require_relative "safe_http"
require_relative "custom_configuration"
require_relative "custom_logger"
require_relative "safe_http"


module BikeIn
  module MastodonBot

    class HistoricalLoader
      SUBSCRIPTION_TYPES_SUPPORTED = ['AirQualityObserved','WeatherObserved','GreenEnergyMeasurement','OffStreetParking','ParkingSpot','BikeHireDockingStation']

      SUBSCRIPTION_ATTR_NOTIFICATION = {
        "AirQualityObserved": ["CO2","NO2","OO3","S02"],
        "WeatherObserved": ["temperature","relativeHumidity"],

        "OffStreetParking": ["status", "location", "availableSpotNumber", "totalSpotNumber"],
        "BikeHireDockingStation": ["freeSlotNumber","status","availableBikeNumber"],

        "GreenEnergyMeasurement": ["eolicPowerGenerated","solarPowerGenerated","refGreenEnergyGenerator"],
      }

      # off_street_parking_id = "urn:ngsi-ld:OffStreetParking:santander:parking:3717862a00f88c61"
      # bike_hire_docking_station_id = "urn:ngsi-ld:BikeHireDockingStation:santander:transportation:00000080A3B83E61"
      # green_energy_measurement_id = "urn:ngsi-ld:GreenEnergyMeasurement:santander:greenenergy:5c6ab6d95372df39200138b0"
      # weather_observed = "urn:ngsi-ld:WeatherObserved:santander:enviroment:5c6ab6d95372df39200138b0"
      # air_quality_observed = "urn:ngsi-ld:AirQualityObserved:santander:enviroment:5c6ab6d95372df39200138b0"

      def initialize
        @logger = BikeIn::Common::CustomLogger.new self.to_s
      end


      def generation_energy_n_days_ago(days_ago, type_generation, sample_limit)
        start_time=Time.at((Time.now - (60*60*24*days_ago) )).strftime("%Y-%m-%dT00:00:00Z")
        end_time=Time.at((Time.now )).strftime("%Y-%m-%dT23:59:00Z")
        # entity_id = "urn:ngsi-ld:GreenEnergyMeasurement:santander:greenenergy:5c6ab6d95372df39200138b0"
        entity_id = $config[:entities][:green_energy_measurement][:id]
        attributte = type_generation # "solarPowerGenerated", "eolicPowerGenerated"
        timerel = "before" # before, after, between
        url = URI("#{$config[:synchronicity][:historical][:protocol]}://#{$config[:synchronicity][:historical][:url]}:#{$config[:synchronicity][:historical][:port]}/v2/entities/#{entity_id}/attrs/#{attributte}?timerel=after&time=#{start_time}&endtime=#{end_time}&limit=#{sample_limit}&offset=0")
        opts = { use_ssl: url.scheme == 'https' }
        response = ::Network::SafeNetHTTP.start(url,opts) do |http|
          http.request(
            Net::HTTP::Get.new(url).tap do |request|
              request["Fiware-Service"] = $config[:synchronicity][:historical][:fiware_service] if $config[:synchronicity][:historical][:fiware_service_enable]
              # request["Authorization"] = "Bearer #{token}" # TODO:
              # request["X-Auth-Token"] = '12234'       # TODO:
            end
          )
        end
        data = parse_json_response(response)
        data
      end

      def parse_json_response(response)
        sane = response || NullResponse.new("[]", 200)
        JSON.parse(sane.read_body.to_s, symbolize_names: true) unless sane.code == "204"
      rescue JSON::ParserError => pe
        @logger.error("#{self.class.name}.#{parse_http} - #{pe.class}: #{pe.message}\nBody: #{sane.read_body}")
        []
      end

    end

  end
end
