# Generate Twitch games

Using Twitch API get all games on twitch.

## Usage:
```console
just release
./bin/twitch_filter_games
```
Will generate two json files in './dist' directory:
'./dist/top_games_list.json' game has fields id, name, box_art_url
'./dist/top_games_list_small.json' game has fields id, name
