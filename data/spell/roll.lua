local Roll = {}
Roll.code = 'roll'

Roll.hp = .1
Roll.distance = 100

Roll.activate = function(self)
  self.hp = Roll.hp
  self.angle = self.owner.angle + (math.pi / 2)
  table.insert(self.owner.auxVex, {speed = self.distance / self.hp, angle = self.angle, t = self.hp})
end

Roll.update = function(self)
  self.hp = timer.rot(self.hp, function()
    ovw.spells:deactivate(self)
  end)
end

return Roll
