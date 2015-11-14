local DeathDesaturate = {}
DeathDesaturate.code = 'deathDesaturate'

function DeathDesaturate:init()
  self.amount = 1
  self:resize()
end

function DeathDesaturate:update()
  if ctx.id and ctx.players:get(ctx.id).ded then
    self.amount = math.lerp(self.amount, 0.4, 4 * tickRate)
  else
    self.amount = 1
  end

  self.shader:send('amount', self.amount)
end

function DeathDesaturate:resize()
  self.shader = data.media.shaders.desaturate
end

return DeathDesaturate
