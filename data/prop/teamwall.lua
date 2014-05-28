local TeamWall = {}
TeamWall.name = 'TeamWall'
TeamWall.code = 'teamwall'

TeamWall.collision = {}
TeamWall.collision.shape = 'rectangle'
TeamWall.collision.static = true
TeamWall.collision.tag = 'teamwall'

function TeamWall:activate()
  ctx.event:emit('collision.attach', {object = self})
end

function TeamWall:draw()
  love.graphics.setColor(255, 0, 0)
  love.graphics.rectangle('fill', self.x, self.y, self.x + self.width, self.y + self.height)
end

return TeamWall
