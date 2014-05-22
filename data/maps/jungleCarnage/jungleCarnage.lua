local jungleCarnage = {}

----------------
-- Meta
----------------
jungleCarnage.name = 'Jungle Carnage'
jungleCarnage.width = 1600
jungleCarnage.height = 1200
jungleCarnage.background = data.media.graphics.map.grass
jungleCarnage.wallTexture = 'wallStone'


----------------
-- Spawn Points
----------------
jungleCarnage.spawn = {}

jungleCarnage.spawn[purple] = {
    x = 128,
    y = 128
}

jungleCarnage.spawn[orange] = {
    x = jungleCarnage.width - 128,
    y = jungleCarnage.height - 128
}

return jungleCarnage
