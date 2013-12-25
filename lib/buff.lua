Buff = class()

function Buff:init()
  self.timer = self.duration
end

function Buff:update()
  self.hp = timer.rot(self.hp, function() ovw.buffs:remove(self) end)
end