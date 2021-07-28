import asyncdispatch, httpclient, json, os, strformat, strutils

proc getAccessToken(): Future[string] {.async.} =
  let client_secret = getEnv("TWITCH_CLIENT_SECRET")
  if client_secret.len == 0:
    echo "No environment variable TWITCH_CLIENT_SECRET found"
    return
  var client = newAsyncHttpClient()
  client.headers = newHttpHeaders({
     "Host": "id.twitch.tv",
     "Connection": "close",
     "Accept": "application/vnd.twitchtv.v5+json"
  })
  let url = &"https://id.twitch.tv/oauth2/token?client_id=7v5r973dmjp0nd1g43b8hcocj2airz&client_secret={client_secret}&grant_type=client_credentials"
  let r = await client.post(url)
  if not r.status.startsWith("200"):
    echo &"Http request returned invalid status code: {r.status}"
    return
  let body = await r.body
  let j = parseJson(body)
  let access_token = j["access_token"].getStr()
  if access_token.len == 0:
    echo "Access token not found"
    return

  return access_token

proc asyncMain(): Future[void] {.async.} =
  const token_file = "tmp/twitch_access_token.txt"
  var access_token = ""
  if fileExists(token_file):
    let f = open(token_file)
    access_token = f.readAll().strip()
    f.close()

  if access_token.len == 0:
    echo "Getting access token"
    access_token = await getAccessToken()
    let f = open(token_file, fmReadWrite)
    f.write(access_token)
    f.close()

  echo &"Token: {access_token}"
  discard


waitFor asyncMain()
