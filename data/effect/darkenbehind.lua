local DarkenBehind = {}
DarkenBehind.code = 'darkenBehind'
DarkenBehind.shader = data.media.shaders.darkenBehind

function DarkenBehind:update()
  if not ctx.id then return end
  local p = ctx.players:get(ctx.id)
  if p then
    self.shader:send('playerPosition', {(p.x - ctx.view.x) * ctx.view.scale, (p.y - ctx.view.y) * ctx.view.scale})
    self.shader:send('screenHeight', ctx.view.frame.height + ctx.view.frame.y)
    self.shader:send('playerDirection', math.deg(p.angle) % 360 + 360)
  end
end

return DarkenBehind