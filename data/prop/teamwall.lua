local TeamWall = {}
TeamWall.name = 'TeamWall'
TeamWall.code = 'teamwall'

TeamWall.collision = {}
TeamWall.collision.shape = 'rectangle'
TeamWall.collision.tag = 'teamwall'

function TeamWall:activate()
  ctx.event:emit('collision.attach', {object = self})
  if ctx.view then ctx.view:register(self) end
end

function TeamWall:deactivate()
  ctx.event:emit('collision.detach', {object = self})
  if ctx.view then ctx.view:unregister(self) end
end

function TeamWall:draw()
  if ctx.id and ctx.players:get(ctx.id).team ~= self.team then
    love.graphics.setColor(150, 0, 0, (1 + math.sin(.0005 * tick / tickRate)) * 20)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
  end
end

return TeamWall
