local BoundsWall = {}
BoundsWall.name = 'BoundsWall'
BoundsWall.code = 'boundswall'

BoundsWall.collision = {}
BoundsWall.collision.shape = 'rectangle'
BoundsWall.collision.static = true
BoundsWall.collision.tag = 'wall'

function BoundsWall:activate()
  ctx.event:emit('collision.attach', {object = self})
end

return BoundsWall
