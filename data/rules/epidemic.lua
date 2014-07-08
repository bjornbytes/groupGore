local Epidemic = {}

Epidemic.code = 'epidemic'

function Epidemic:init()
  self.winner = nil
  self.restartTimer = 0
  self.timer = 5 * 60

  ctx.event:on(evtDead, function(_data)
    if self.restartTimer > 0 or _data.id == _data.kill then return end
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

  ctx.event:on('game.restart', function(data)
    self.points[purple] = 0
    self.points[orange] = 0
    self.winner = nil
    self.restartTimer = 0
  end)
end

function Epidemic:update()
  self.timer = timer.rot(self.timer, function()
    self.winner = purple
    self.restartTimer = 6
    ctx.net:emit(evtChat, {message = 'purple team wins!'})
  end)

  self.restartTimer = timer.rot(self.restartTimer, function()
    self.winner = nil
    ctx.event:emit('game.quit')
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
    self.winner = orange
    self.restartTimer = 6
  end
end

return Epidemic