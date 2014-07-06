local SpawnRoom = {}
SpawnRoom.name = 'SpawnRoom'
SpawnRoom.code = 'spawnroom'

SpawnRoom.collision = {}
SpawnRoom.collision.shape = 'rectangle'
SpawnRoom.collision.static = true
SpawnRoom.collision.tag = 'spawnroom'

function SpawnRoom:activate()
  ctx.event:emit('collision.attach', {object = self})
end

return SpawnRoom
