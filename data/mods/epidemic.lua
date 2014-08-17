local Epidemic = {}
Epidemic.code = 'epidemic'

function Epidemic:init(map)
  self.timer = 5 * 60

  ctx.event:on(evtDead, function(_data)
    if _data.id == _data.kill then return end
    local p = ctx.players:get(_data.id)
    if p.team == purple then
      ctx.net:emit(evtClass, {id = _data.id, class = p.class.id, team = orange})
      ctx.players:each(function(p)
        if p.team == orange then ctx.buffs:add(p, 'zombieboost') end
      end)
    end
  end)

  ctx.event:on(evtClass, function(data) self:refresh() end)
  ctx.event:on(msgLeave, function(data) self:refresh() end)

  for i = #map.props, 1, -1 do
    local p = map.props[i]
    if (p.code == 'spawnroom' or p.code == 'teamwall') and p.team == purple then
      p:deactivate()
      table.remove(map.props, i)
    end
  end
end

function Epidemic:update()
  self.timer = timer.rot(self.timer, function()
    ctx.map:modExec('scoring', 'win', purple)
  end)

  ctx.players:each(function(p)
    if p.team == orange and not ctx.buffs:get(p, 'zombie') then ctx.buffs:add(p, 'zombie') end
  end)
end

function Epidemic:refresh()
  if tick < 10 / tickRate then return end
  local purples = 0
  ctx.players:each(function(p)
    if p.team == purple then purples = purples + 1 end
  end)
  if purples == 0 then
    ctx.map:modExec('scoring', 'win', orange)
  end
end

return Epidemic