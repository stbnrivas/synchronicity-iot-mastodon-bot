# synchronicity-iot-mastodon-bot

a bot for consume data from fiware/synchronicity and publish it in mastodon




# a handful of requests
create an app

```bash
APP

curl -X POST \
  -d "client_name=leantusk&redirect_uris=urn:ietf:wg:oauth:2.0:oob&scopes=write read&website=http://leancrew.com" \
  https://mastodon.cloud/api/v1/apps

curl -X POST -sS https://botsin.space/api/v1/apps \
  -F "client_name=${APP}" \
  -F "redirect_uris=urn:ietf:wg:oauth:2.0:oob" \
  -F "scopes=read"
```

get token

```bash
curl -X POST  \
-d "client_id=&client_secret=&grant_type=password&username=&password=&scope=read" \
-Ss "https://botsin.space/auth/token"



# example

curl -X POST \
  -d "client_id= alongstringofcharacters&client_secret= anotherlongstring&scope=write read&grant_type= password&username= myusername&password= mypassword" https://mastodon.cloud/oauth/token



{"access_token":"this-is-not-your-business","token_type":"Bearer","scope":"write read","created_at":2566902025}
```
