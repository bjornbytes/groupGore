local DarkenBehind = {}
DarkenBehind.code = 'darkenBehind'
DarkenBehind.shader = data.media.shaders.darkenBehind

function DarkenBehind:init()
  self:resize()
end

function DarkenBehind:update()
  if not ctx.id then return end
  local p = ctx.players:get(ctx.id)
  if p then
    self.shader:send('playerPosition', {(p.drawX - ctx.view.x) * ctx.view.scale, (p.drawY - ctx.view.y) * ctx.view.scale})
    self.shader:send('playerDirection', math.deg(p.angle) % 360 + 360)
  end
end

function DarkenBehind:resize()
  self.shader:send('frame', {ctx.view.frame.x, ctx.view.frame.y, ctx.view.frame.width, ctx.view.frame.height})
end

return DarkenBehind