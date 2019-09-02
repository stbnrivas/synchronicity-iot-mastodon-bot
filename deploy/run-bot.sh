BOT_ENV="development"
MASTODON_INSTANCE_URL="https://botsin.space"
DOCKER_IMG="bot"
DOCKER_TAG="1.0"
LOG_FILE="mastodon_bot.log"

/usr/bin/docker run \
  --name santander-bot \
  --rm \
  --env-file=/bot/bot.env \
  --volume /bot/${LOG_FILE}:/bot/${LOG_FILE} \
  ${DOCKER_IMG}:${DOCKER_TAG}
