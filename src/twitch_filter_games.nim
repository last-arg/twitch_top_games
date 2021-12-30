import asyncdispatch, httpclient, json, os, strformat, strutils, options

type
  Game = ref object
    id: string
    name: string
    box_art_url: string

  Pagination = ref object
    cursor: Option[string]

  Games = ref object
    data: seq[Game]
    pagination: Pagination

  GameTrimmed = ref object
    id: string
    name: string

proc requestAccessToken(client_id: string, client_secret: string): Future[string] {.async.} =
  var client = newAsyncHttpClient()
  client.headers = newHttpHeaders({
     "Host": "id.twitch.tv",
     "Connection": "close",
     "Accept": "application/vnd.twitchtv.v5+json"
  })
  let url = &"https://id.twitch.tv/oauth2/token?client_id={client_id}&client_secret={client_secret}&grant_type=client_credentials"
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

  client.close()
  return access_token

proc fetchGames(client_id: string, token: string): Future[seq[Game]] {.async.} =
  var games: seq[Game] = @[]
  var client = newAsyncHttpClient()
  client.headers = newHttpHeaders({
    "Host": "api.twitch.tv",
    "Connection": "close",
    "Authorization": &"Bearer {token}",
    "Accept": "application/vnd.twitchtv.v5+json",
    "Client-Id": client_id
  })
  var cursor = ""
  while true:
    let url = &"https://api.twitch.tv/helix/games/top?first=100&after={cursor}"
    let r = await client.get(url)
    if not r.status.startsWith("200"):
      echo &"Http request returned invalid status code: {r.status}"
      return
    let body = await r.body
    let j = parseJson(body)
    let g = to(j, Games)
    games.add(g.data)
    if g.pagination.cursor.isNone():
      break
    cursor = g.pagination.cursor.unsafeGet()

  client.close()
  return games

proc asyncMain(): Future[void] {.async.} =
  # TODO: add TWITCH_CLIENT_ID env var 
  let client_id = getEnv("TWITCH_CLIENT_ID")
  if client_id.len == 0:
    echo "No environment variable TWITCH_CLIENT_ID found"
    return
  let client_secret = getEnv("TWITCH_CLIENT_SECRET")
  if client_secret.len == 0:
    echo "No environment variable TWITCH_CLIENT_SECRET found"
    return

  echo "Getting twitch access token"
  let access_token = await requestAccessToken(client_id, client_secret)
  # echo &"Token: {access_token}"

  if access_token.len == 0:
    echo "Failed to get access token. Make sure environment variables TWITCH_CLIENT_ID and TWITCH_CLIENT_SECRET are correct"
    return

  echo "Downloading all top games"
  let games = await fetchGames(client_id, access_token)
  echo &"Number of games: {games.len}"
  let json_content = %*{"data": games}
  let f = open("dist/top_games_list.json", fmReadWrite)
  f.write($json_content)
  f.close()
  echo &"Generated 'dist/top_games_list.json'"

  let f_small = open("dist/top_games_list_small.json", fmReadWrite)
  let games_small = cast[seq[GameTrimmed]](games)
  let json_content_small = %*{"data": games_small}
  f_small.write($json_content_small)
  f_small.close()
  echo &"Generated 'dist/top_games_list_small.json'"

waitFor asyncMain()
