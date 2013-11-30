Buff = {}

function Buff:add(player, b, ...)
  if self:getBuff(player, b) then return end
  local buff = {}
  setmetatable(buff, {__index = b})
  player.buffs[buff.code] = buff
  
  for fn, x in pairs(buff.effects or {}) do
    self[fn](self, player, false, x, ...)
  end
  
  f.exe(buff.activate, player, buff)
end

function Buff:remove(player, b, ...)
  local buff = self:getBuff(player, b)
  if not buff then return end
  
  for fn, x in pairs(buff.effects or {}) do
    self[fn](self, player, true, x, ...)
  end
  
  player.buffs[buff.code] = nil
  f.exe(buff.deactivate, player, buff)
end

function Buff:getBuff(player, b)
  return player.buffs[b.code]
end

function Buff:haste(player, undo, percent)
  if undo then
    player.maxSpeed = player.maxSpeed - (player.class.speed * percent)
  else
    player.maxSpeed = player.maxSpeed + (player.class.speed * percent)
  end
end