# Twitch top games
Get currently all available twitch top games.

## Motivation
Thought that was going to need for another project. But this will only get currently live games/categories. I would have needed all the games/categories on twitch.

## Usage:
```console
just release
# can also export environment variables before calling the command
TWITCH_CLIENT_ID=<client-id> TWITCH_CLIENT_SECRET=<client-secret> ./bin/twitch_filter_games
```
Will generate two json files:
- './dist/top_games_list.json' game has fields id, name, box_art_url
- './dist/top_games_list_small.json' game has fields id, name
