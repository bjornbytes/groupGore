local Knife = {}

Knife.name = 'Knife'
Knife.code = 'knife'
Knife.text = 'Stabby'
Knife.type = 'weapon'

Knife.damage = 45
Knife.cooldown = .8

function Knife:activate(knife)
  knife.timer = 0
end

function Knife:update(knife)
  knife.timer = timer.rot(knife.timer)
end

function Knife:canFire(knife)
  return knife.timer == 0
end

function Knife:fire(knife)
  ctx.spells:activate(self.id, data.spell.knife)
  knife.timer = knife.cooldown
end

function Knife:draw(knife)
  --
end

return Knife
