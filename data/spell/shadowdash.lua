local ShadowDash = {}
ShadowDash.code = 'shadowdash'
ShadowDash.distance = 160
ShadowDash.hp = .1

function ShadowDash:activate()
  self.hp = ShadowDash.hp
  self.angle = self.owner.angle
  if ovw.sound then ovw.sound:play('dash') end
  if ovw.buffs:get(self.owner, 'shadowform') then
    self.owner.x = self.owner.x + math.dx(self.distance, self.angle)
    self.owner.y = self.owner.y + math.dy(self.distance, self.angle)
    ovw.collision:update()
    ovw.spells:deactivate(self)
  end
end

function ShadowDash:update()
  self.hp = timer.rot(self.hp, function() ovw.spells:deactivate(self) end)
  self.owner.x = self.owner.x + math.dx(self.distance / ShadowDash.hp * tickRate, self.angle)
  self.owner.y = self.owner.y + math.dy(self.distance / ShadowDash.hp * tickRate, self.angle)
  ovw.collision:update()
end

function ShadowDash:draw()
  --
end

return ShadowDash