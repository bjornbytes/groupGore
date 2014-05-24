local Dusk = {}

Dusk.name = 'Dusk'
Dusk.code = 'dusk'
Dusk.text = 'Move through the shadows.'
Dusk.type = 'skill'

Dusk.cooldown = 8

function Dusk:activate(owner)
  self.timer = 0
  self.stacks = 2
end

function Dusk:update(owner)
  self.timer = timer.rot(self.timer, function()
  	if self.stacks == 0 then self.stacks = 2 end
  end)
end

function Dusk:canFire(owner)
  return self.timer == 0 and self.stacks > 0
end

function Dusk:fire(owner, mx, my)
  ctx.spells:activate(owner.id, data.spell.dusk, mx, my)
  self.stacks = self.stacks - 1
  self.timer = self.stacks == 0 and self.cooldown or .15
end

function Dusk:value(owner)
	if self.stacks > 0 then return self.timer / .15 end
  return self.timer / self.cooldown
end

return Dusk
