local Roll = {}
Roll.code = 'roll'

Roll.hp = .1
Roll.distance = 100

Roll.activate = function(self)
  self.hp = Roll.hp
  self.angle = self.owner.angle + (math.pi / 2)
  self.owner.auxMoveX = self.owner.auxMoveX + math.dx(self.distance / Roll.hp * tickRate, self.angle)
  self.owner.auxMoveY = self.owner.auxMoveY + math.dy(self.distance / Roll.hp * tickRate, self.angle)
end

Roll.update = function(self)
  self.hp = timer.rot(self.hp, function()
    self.owner.auxMoveX = self.owner.auxMoveX - math.dx(self.distance / Roll.hp * tickRate, self.angle)
    self.owner.auxMoveY = self.owner.auxMoveY - math.dy(self.distance / Roll.hp * tickRate, self.angle)
    ovw.spells:deactivate(self)
  end)
end

return Roll
