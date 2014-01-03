local Roll = {}
Roll.code = 'roll'

Roll.hp = .1
Roll.distance = 100

Roll.activate = function(self)
  self.hp = Roll.hp
  self.angle = self.owner.angle + (math.pi / 2)
end

Roll.update = function(self)
  self.hp = timer.rot(self.hp, function() ovw.spells:deactivate(self) end)
  self.owner.x = self.owner.x + math.dx(self.distance / Roll.hp * tickRate, self.angle)
  self.owner.y = self.owner.y + math.dy(self.distance / Roll.hp * tickRate, self.angle)
end

return Roll
