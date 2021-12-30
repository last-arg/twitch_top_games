release:
  nim c -d:ssl -d:danger --outDir:bin src/twitch_filter_games.nim

build:
  nim c -d:ssl --outDir:bin src/twitch_filter_games.nim

run:
  nim r -d:ssl src/twitch_filter_games.nim

watch:
  watchexec -c -r -w src/ 'just run'
