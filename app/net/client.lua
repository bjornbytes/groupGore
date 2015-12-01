local NetClient = extend(app.net.core)

NetClient.signatures = app.net.signatures.client

NetClient.receive = {}
NetClient.receive['default'] = function(self, event) ctx.event:emit(event.msg, event.data) end

NetClient.receive[app.net.messages.join] = function(self, event)
  ctx.id = event.data.id
  setmetatable(ctx.players:get(ctx.id), {__index = app.player.main})
end

NetClient.receive[app.net.messages.snapshot] = function(self, event)
  ctx.tick = event.data.tick + math.floor(((event.peer:round_trip_time() / 2) / 1000) / tickRate)
  if env ~= 'release' then ctx.tick = event.data.tick end
  --ctx.map:load(event.data.map)
  for i = 1, #event.data.players do
    local p = event.data.players[i]
    ctx.players:get(p.id).username = p.username
    if p.class > 0 then
      ctx.players:activate(p.id)
      ctx.players:setClass(p.id, p.class, p.team)
    end
  end
end

function NetClient:init()
  self.other = app.net.server
  self:connectTo(serverIp, 6061)
  self.messageBuffer = {}

  ctx.event:on(app.net.events.join, function(data)
    ctx.players:get(data.id).username = data.username
  end)

  ctx.event:on(app.net.events.sync, function(data)
    local p = ctx.players:get(data.id)
    if p and p.active then
      p:trace(data)
    end
  end)

  ctx.event:on('game.quit', function(data)
    self:quit()
  end)

  app.net.core.init(self)
end

function NetClient:quit()
  self:send(app.net.messages.leave)
  self.host:flush()
  self.server:disconnect()
end

function NetClient:connect(event)
  self.server = event.peer
  self:send(app.net.messages.join, {username = username})
  event.peer:ping_interval(100)
  event.peer:ping()
end

function NetClient:disconnect(event)
  ctx.event:emit('game.quit')
end

function NetClient:send(msg, data)
  if not self.server then return end

  self.outStream:clear()
  self:pack(msg, data)

  local important = self.signatures[msg].important
  local channel = important and 0 or 1
  local reliability = important and 'reliable' or 'unreliable'
  self.server:send(tostring(self.outStream), channel, reliability)
end

NetClient.emit = f.empty

return NetClient
