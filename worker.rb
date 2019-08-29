require 'dotenv'
require 'json'
require 'mastodon'


require_relative 'lib/custom_configuration'
$config = BikeIn::Common::CustomConfiguration.new
# $config.freeze
$stdout.sync = true # to show logs in heroku
require_relative 'lib/custom_logger'
require_relative 'lib/historical_loader'
require_relative 'lib/diagram_generator'

# pp ENV['BOT_ENV']

def pluralize(n)
  "s" if n > 1
end

@logger = BikeIn::Common::CustomLogger.new "worker.rb"

hist = BikeIn::MastodonBot::HistoricalLoader.new

# pp hist.occupation_n_days_ago(1)
# pp hist.generation_energy_n_days_ago(1,"eolicPowerGenerated")

file_path = "."
file_name_solar = "santander-solar.png"
file_name_eolic = "santander-eolic.png"
file_name_occupation = "santander-occupation.png"
n_days_ago = 1
sample_limit = 800

data_solar = hist.generation_energy_n_days_ago(n_days_ago,"solarPowerGenerated",sample_limit)
data_eolic = hist.generation_energy_n_days_ago(n_days_ago,"eolicPowerGenerated",sample_limit)

@logger.info "sample size for solarPowerGenerated #{data_solar[:solarPowerGenerated].size}"
@logger.info "sample size for eolicPowerGenerated #{data_eolic[:eolicPowerGenerated].size}"


include BikeIn::MastodonBot::Diagram

solar_graphics = print("solar",data_solar[:solarPowerGenerated],file_path,file_name_solar)
@logger.info "solar diagram generated"
eolic_graphics = print("eolica",data_eolic[:eolicPowerGenerated],file_path,file_name_eolic)
@logger.info "eolic diagram generated"

mastodon_url = "#{$config[:mastodon][:instance][:protocol]}://#{$config[:mastodon][:instance][:url]}:#{$config[:mastodon][:instance][:port]}"

client  = Mastodon::REST::Client.new(
  base_url: mastodon_url,
  bearer_token: $config[:mastodon][:instance][:access_token])

form = HTTP::FormData::File.new(file_name_eolic)
media = client.upload_media(form)
status = "la generacion eolica en santander hace #{n_days_ago} dia#{pluralize(n_days_ago)}, #synchronicity #santander #smartcity  #autonomous_hub_for_cyclist (#{Time.now.to_s[0..9]})"
sr = client.create_status(status, media_ids: [media.id], language: "ES")
@logger.info "toot about eolic sent"

form = HTTP::FormData::File.new(file_name_solar)
media = client.upload_media(form)
status = "la generacion solar en santander hace #{n_days_ago} dia#{pluralize(n_days_ago)} #synchronicity #santander #smartcity #autonomous_hub_for_cyclist graficos generados el dia  (#{Time.now.to_s[0..9]}) "
sr = client.create_status(status, media_ids: [media.id], language: "ES")
@logger.info "toot about solar sent"

File.delete("#{file_path}/#{file_name_solar}") if File.exist?("#{file_path}/#{file_name_solar}")
File.delete("#{file_path}/#{file_name_eolic}") if File.exist?("#{file_path}/#{file_name_eolic}")
@logger.info "files deletion ended"
