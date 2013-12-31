Buffs = class()

function Buffs:init()
  self.buffs = {}
end

function Buffs:add(kind, source, target)
  local buff = kind()
  buff.source = source
  buff.target = target

  table.insert(self.buffs, buff)

  source = ovw.players:get(buff.source)
  target = ovw.players:get(buff.target)
  table.each(buff.effects, function(val, effect)    
    if effect == 'shield' and target.shields then
      table.insert(target.shields, table.copy(val))
    end
  end)

  return buff
end

function Buffs:remove(target, code)
  self.buffs = table.filter(self.buffs, function(b) return b.target ~= target and (code and (b.code ~= code) or true) end)
end

function Buffs:update()
  table.each(self.buffs, function(buff, i)
    self:undo(buff)
    if buff:update() then return table.remove(self.buffs, i) end
    self:apply(buff)
  end)
end

function Buffs:undo(buff)
  local source = ovw.players:get(buff.source)
  local target = ovw.players:get(buff.target)
  table.each(buff.undo, function(v, k)
    target[k] = target[k] + v
  end)
  table.clear(buff.undo)
end

function Buffs:apply(buff)
  local source = ovw.players:get(buff.source)
  local target = ovw.players:get(buff.target)
  table.each(buff.effects, function(val, effect)
    if effect == 'haste' then
      val = target.maxSpeed * val
      target.maxSpeed = target.maxSpeed + val
      buff.undo.maxSpeed = -val
    elseif effect == 'dot' and (not buff.dotTick or tick - buff.dotTick > (.5 / tickRate)) then
      ovw.net:emit(evtDamage, {id = target.id, amount = val * .5, from = source.id, tick = tick})
      buff.dotTick = tick
    elseif effect == 'hot' and (not buff.hotTick or tick - buff.hotTick > (.5 / tickRate)) then
      target:heal({amount = val * .5})
      buff.hotTick = tick
    end
  end)
end