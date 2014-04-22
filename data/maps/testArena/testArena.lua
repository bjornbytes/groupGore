local testArena = {}

----------------
-- Meta
----------------
testArena.name = 'Test Arena'
testArena.width = 800
testArena.height = 600
testArena.weather = nil
testArena.background = data.media.graphics.map.grass


----------------
-- Spawn Points
----------------
testArena.spawn = {}
testArena.spawn[purple] = {
    x = 64,
    y = 300
}
testArena.spawn[orange] = {
    x = testArena.width - 64,
    y = 300
}

return testArena
