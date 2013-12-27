Buffs = class()

function Buffs:init()
  self.buffs = {}
end

function Buffs:add(kind, source, target)
  local buff = kind()
  buff.source = source
  buff.target = target

  table.insert(self.buffs, buff)
  return buff
end

function Buffs:removeByTarget(id)
  self.buffs = table.filter(self.buffs, function(b) return b.target ~= id end)
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
  table.each(buff.effects, function(vals, effect)
    if type(vals) ~= 'table' then vals = {vals} end
    table.each(vals, function(val)
      if type(val) == 'function' then val = val(target) end
      
      if effect == 'haste' then
        target.maxSpeed = target.maxSpeed + val
        buff.undo.maxSpeed = -val
      elseif effect == 'dot' then
        ovw.net:emit(evtDamage, {id = target.id, amount = val * tickRate, from = source.id, tick = tick})
      elseif effect == 'hot' then
        target:heal(val * tickRate)
      end
    end)
  end)
end