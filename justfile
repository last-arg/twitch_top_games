release:
  nim c -d:ssl -d:release --outDir:bin src/twitch_filter_games.nim

build:
  nim c -d:ssl src/twitch_filter_games.nim

run:
  nim r -d:ssl src/twitch_filter_games.nim

watch:
  watchexec -c -r -w src/ 'just run'
