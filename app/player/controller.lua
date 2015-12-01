local Players = class()
Players.max = 15

function Players:init()
  self.players = {}
  self.active = {}

  for i = 1, self.max do
    self.players[i] = ctx.tag == 'server' and app.player.server() or app.player.dummy()
    self.players[i].id = i
  end

  ctx.event:on(app.net.events.leave, function(data)
    self:deactivate(data.id)
  end)

  ctx.event:on(app.net.events.class, function(data)
    self:setClass(data.id, data.class, data.team)
  end)

  ctx.event:on(app.net.events.fire, function(data)
    if ctx.id and data.id ~= ctx.id then
      local p = self:get(data.id)
      local slot = p.slots[data.slot]
      slot:fire(p, data.mx, data.my)
    end
  end)

  ctx.event:on(app.net.events.damage, function(data)
    local to, from = self:get(data.id), self:get(data.from)
    to.lastHurt = tick
    if data.id ~= data.from then
      from.lastDamageDealt = tick
    end
    data.amount = data.amount * to.damageInMultiplier * from.damageOutMultiplier
    to:hurt(data)
    local oldAmt = data.amount
    data.amount = data.amount * from.lifesteal
    if data.id ~= data.from then
      from:heal(data)
    end
    data.amount = oldAmt
    ctx.event:emit('particle.create', {
      kind = 'arcadetext',
      vars = {
        x = to.x,
        y = to.y,
        str = tostring(math.round(tonumber(data.amount)))
      }
    })
  end)

  ctx.event:on(app.net.events.dead, function(data)
    local killer, victim = self:get(data.kill), self:get(data.id)
    if data.kill ~= data.id then
      killer.kills = killer.kills + 1
    end
    victim.deaths = victim.deaths + 1
    victim.killer = killer
    victim:die()
  end)

  ctx.event:on(app.net.events.spawn, function(data)
    local p = self:get(data.id)
    p.ded = false
    p:spawn()
  end)

  ctx.event:on('game.restart', function(data)
    self:each(function(p)
      ctx.net:emit(app.net.events.spawn, {id = p.id})
    end)
  end)
end

function Players:activate(id)
  if ctx.view then ctx.view:register(self.players[id]) end
  ctx.event:emit('collision.attach', {object = self.players[id]})
  table.insert(self.active, id)
end

function Players:deactivate(id)
  if ctx.view then ctx.view:unregister(self.players[id]) end
  ctx.event:emit('collision.detach', {object = self.players[id]})
  self.players[id]:deactivate()
  for i = 1, self.max do
    if self.active[i] == id then table.remove(self.active, i) break end
  end
end

function Players:get(id, t)
  return self.players[id]:get(t or tick)
end

function Players:each(fn)
  for i = 1, #self.active do
    fn(self:get(self.active[i]))
  end
end

function Players:update()
  self:each(f.ego('update'))
end

function Players:setClass(id, class, team)
  local p = self.players[id]
  if not table.has(self.active, id) then self:activate(id) end
  p.class = data.class[data.class.list[class]]
  p.team = team
  p:activate()
end

return Players
