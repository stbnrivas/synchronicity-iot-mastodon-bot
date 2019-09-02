# synchronicity-iot-mastodon-bot

a bot for consume data from fiware/synchronicity and publish it in mastodon


# run the bot using systemd timers

- install docker

## unit creation


```bash
sudo vi /etc/systemd/system/bot.service
```

```[Unit]
Description=launch bot

[Service]
Type=simple
ExecStart=/bin/bash /bot/run-bot.sh

[Install]
#Alias=bot.service
WantedBy=multi-user.target
```


```bash
sudo systemctl list-units | grep .service
sudo systemctl is-enabled bot
sudo systemctl enable bot
sudo systemctl start bot
```

## timer creation

```bash
sudo vi /etc/systemd/system/timers.target.wants/bot.timer
```

```
[Unit]
Description=runs mastodon bot every day
[Timer]
OnCalendar=*-*-* 12:00:00
Persistent=true
[Install]
WantedBy=timers.target
```

```bash
sudo systemctl daemon-reload
systemctl list-timers
sudo systemctl enable bot.timer
sudo systemctl status bot.timer
sudo systemctl start bot.timer
```
