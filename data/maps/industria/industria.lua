local industria = {}

----------------
-- Meta
----------------
industria.name = 'Industria'
industria.width = 2432
industria.height = 3320
industria.wallTexture = 'wallSnow'
industria.weather = 'snow'
industria.soundscape = 'blizzard'

----------------
-- Textures
----------------
industria.textures = {
  background = {1, 1, 256, 256},
  wall = {259, 1, 64, 64},
  metal = {259, 67, 64, 64},
  crate = {259, 133, 64, 64}
}

----------------
-- Spawn Points
----------------
industria.spawn = {}

industria.spawn[purple] = {
  x = 1376,
  y = 544
}

industria.spawn[orange] = {
  x = 1056,
  y = 2784
}

return industria
