build:
  nim r -d:ssl src/twitch_filter_games.nim

watch:
  watchexec -c -r -w src/ 'just build'
