# Generate Twitch games
Get all top games (have atleast one viewer) using twitch API.

# Motivation
Thought that was going to need for another project. But this will only get currently live games/categories. I would have needed all the games/categories on twitch.

## Usage:
```console
just release
TWITCH_CLIENT_SECRET=<twitch-client-secret> ./bin/twitch_filter_games
```
Will generate two json files in './dist' directory:
'./dist/top_games_list.json' game has fields id, name, box_art_url
'./dist/top_games_list_small.json' game has fields id, name
