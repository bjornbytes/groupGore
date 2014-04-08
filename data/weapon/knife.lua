local Knife = {}

Knife.name = 'Knife'
Knife.code = 'knife'
Knife.text = 'Stabby'
Knife.type = 'weapon'

Knife.reload = .1

function Knife:activate(knife)
  knife.timers = {}
  knife.timers.reload = 0
end

function Knife:udpate(knife)
  --
end

function Knife:canFire(knife)
  --
end

function Knife:fire(knife)
  --
end

function Knife:draw(knife)
  --
end

return Knife