Buffs = {}

function Buffs:add(player, b)
  if self:getBuff(player, b) then return end
  local buff = {}
  setmetatable(buff, {__index = b})
  player.buffs[buff.code] = buff
  
  for fn, x in pairs(buff.effects) do
    self[fn](self, player, x, true)
  end
end

function Buffs:remove(player, b)
  local buff = self:getBuff(player, b)
  if not buff then return end
  
  for fn, x in pairs(buff.effects) do
    self[fn](self, player, x, false)
  end
  
  player.buffs[buff.code] = nil
end

function Buffs:getBuff(player, b)
  return player.buffs[b.code]
end

function Buffs:haste(player, percent, apply)
  if apply then
    player.maxSpeed = player.maxSpeed + (player.class.speed * percent)
  else
    player.maxSpeed = player.maxSpeed - (player.class.speed * percent)
  end
end