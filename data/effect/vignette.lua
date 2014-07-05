local Vignette = {}
Vignette.code = 'vignette'
Vignette.shader = data.media.shaders.vignette

function Vignette:init()
  self.radius = .85
  self.shader:send('radius', self.radius)
  self.shader:send('blur', .45)
  self:resize()
end

function Vignette:update()
  if not ctx.id then return end
  local p = ctx.players:get(ctx.id)
  if p and p.slots[p.weapon] and p.slots[p.skill] and (p.slots[p.weapon].targeting or p.slots[p.skill].targeting) then
    self.radius = math.lerp(self.radius, .8, math.min(10 * tickRate, 1))
    self.shader:send('radius', self.radius)
  else
    self.radius = math.lerp(self.radius, .85, math.min(10 * tickRate, 1))
    self.shader:send('radius', self.radius)
  end
end

function Vignette:resize()
  self.shader:send('frame', {ctx.view.frame.x, ctx.view.frame.y, ctx.view.frame.width, ctx.view.frame.height})
end

return Vignette