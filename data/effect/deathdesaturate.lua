local DeathDesaturate = {}
DeathDesaturate.code = 'deathDesaturate'
DeathDesaturate.shader = data.media.shaders.desaturate

function DeathDesaturate:init()
  self.amount = 1
end

function DeathDesaturate:update()
  if ctx.id and ctx.players:get(ctx.id).ded then
    self.amount = math.lerp(self.amount, 0.4, 4 * tickRate)
  else
    self.amount = 1
  end

  self.shader:send('amount', self.amount)
end

return DeathDesaturate