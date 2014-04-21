local ShadowDash = {}
ShadowDash.code = 'shadowdash'
ShadowDash.distance = 160
ShadowDash.hp = .1

function ShadowDash:activate()
  self.hp = ShadowDash.hp
  self.angle = self.owner.angle
  ctx.event:emit('sound.play', {sound = 'dash'})
  if ctx.buffs:get(self.owner, 'shadowform') then
    self.owner.x = self.owner.x + math.dx(self.distance, self.angle)
    self.owner.y = self.owner.y + math.dy(self.distance, self.angle)
    ctx.collision:update()
    ctx.spells:deactivate(self)
  end
end

function ShadowDash:update()
  self.hp = timer.rot(self.hp, function() ctx.spells:deactivate(self) end)
  self.owner.x = self.owner.x + math.dx(self.distance / ShadowDash.hp * tickRate, self.angle)
  self.owner.y = self.owner.y + math.dy(self.distance / ShadowDash.hp * tickRate, self.angle)
  ctx.collision:update()
end

function ShadowDash:draw()
  --
end

return ShadowDash
