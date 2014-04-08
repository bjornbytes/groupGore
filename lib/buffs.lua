Buffs = class()

function Buffs:init()
  self.buffs = {}
end

function Buffs:update()
  table.with(self.buffs, 'update')
end

function Buffs:add(player, code)
  assert(not self:get(player, code))
  
  local buff = new(data.buff[code])
  buff.owner = player
  f.exe(buff.activate, buff)

  table.insert(self.buffs, buff)

  return buff
end

function Buffs:remove(player, code)
  local buff = self:get(player, code)
  if buff then
    f.exe(buff.deactivate, buff)
    table.remove(self.buffs, i)
  end
end

function Buffs:get(player, code)
  for i = 1, #self.buffs do
    local buff = self.buffs[i]
    if buff.owner == player and buff.code == code then
      return buff
    end
  end
end