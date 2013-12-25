Buffs = class()

function Buffs:init()
  self.buffs = {}
end

function Buffs:add(kind, source, target)
  local buff = kind()

  table.insert(self.buffs, buff)
end

function Buffs:remove()
  --
end

function Buffs:update()
  table.each(self.buffs, function(buff, i)

  end)
end