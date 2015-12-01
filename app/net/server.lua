local NetServer = extend(app.net.core)

NetServer.signatures = app.net.signatures.server

NetServer.receive = {}
NetServer.receive['default'] = f.empty

NetServer.receive[app.net.messages.join] = function(self, event)
  local pid = self.peerToPlayer[event.peer]
  ctx.players:get(pid).username = event.data.username
  self:send(app.net.messages.join, event.peer, {id = pid})
  self:emit(app.net.events.join, {id = pid, username = event.data.username})
  self:emit(app.net.events.chat, {message = '{white}' .. event.data.username .. ' has joined!'})
  self:snapshot(event.peer)
end

NetServer.receive[app.net.messages.leave] = function(self, event) self:disconnect(event) end

NetServer.receive[app.net.messages.class] = function(self, event)
  self:emit(app.net.events.class, {id = self.peerToPlayer[event.peer], class = event.data.class, team = event.data.team})
end

NetServer.receive[app.net.messages.input] = function(self, event)
  ctx.players:get(self.peerToPlayer[event.peer]):trace(event.data, event.peer:round_trip_time())
end

NetServer.receive[app.net.messages.chat] = function(self, event)
  local pid = self.peerToPlayer[event.peer]
  local username = ctx.players:get(pid).username
  local color = ctx.players:get(pid).team == 0 and 'purple' or 'orange'
  local message = event.data.message
  if message:sub(1, 1) == '/' then
    local data = {}
    for word in string.gmatch(message, '([^ ]+)') do
      table.insert(data, word)
    end
    local function reply(message) self:send(app.net.events.chat, event.peer, {message = '{red}' .. message}) end
    local handlers = {
      ['/restart'] = function(data)
        if username ~= ctx.owner then return reply('permission denied') end
        ctx.event:emit('game.restart')
        reply('game restarted')
      end,

      ['/kick'] = function(data)
        if username ~= ctx.owner then return reply('permission denied') end
        if not data[2] or #data[2] == 0 then return reply('who are we kicking?') end
        if data[2] == ctx.owner then return reply('don\'t be so masokicktic! *pats on back*') end
        local player, peer
        for i = 1, ctx.players.max do
          if ctx.players:get(i).username == data[2] then player = i break end
        end
        if not player then return self:send(app.net.events.chat, event.peer, {message = '{red}couldn\'t find player "' .. data[2] .. '"'}) end
        for i = 1, ctx.players.max do
          local p = self.host:get_peer(i)
          if self.peerToPlayer[p] == player then peer = p break end
        end
        if not peer then return self:send(app.net.events.chat, event.peer, {message = '{red}"' .. data[2] .. '" doesn\'t seem to be connected'}) end
        self:disconnect({peer = peer, reason = 'kicked'})
      end,

      ['/roll'] = function(data)
        self:emit(app.net.events.chat, {message = '{red}' .. username .. ' rolled {green}' .. love.math.random(1, 100)})
      end,

      ['/bjorn'] = function(data)
        self:emit(app.net.events.chat, {message = '{purple}-_-'})
      end,

      default = function(data)
        self:send(app.net.events.chat, event.peer, {message = '{red}unknown command "' .. data[1]:sub(2) .. '"'})
      end
    }
    handlers['/reset'] = handlers['/restart']
    handlers['/refresh'] = handlers['/restart']
    handlers['/sakujo'] = handlers['/kick']

    return (handlers[data[1]] or handlers.default)(data)
  end
  self:emit(app.net.events.chat, {message = '{' .. color .. '}' .. username .. '{white}: ' .. message})
end

function NetServer:init()
  self.other = app.net.client

  self:listen(6061)
  self.peerToPlayer = {}
  self.eventBuffer = {}
  self.importantEventBuffer = {}

  ctx.event:on('game.quit', function(data)
    self:quit()
  end)

  app.net.core.init(self)
end

function NetServer:quit()
  if self.host then
    for i = 1, ctx.players.max do
      if self.host:get_peer(i) then self.host:get_peer(i):disconnect_now() end
    end
    self.host:flush()
  end
  self.host = nil
end

function NetServer:connect(event)
  self.peerToPlayer[event.peer] = self:nextPlayerId()
  event.peer:timeout(0, 0, 3000)
  event.peer:ping_interval(100)
  event.peer:ping()
end

function NetServer:disconnect(event)
  local pid = self.peerToPlayer[event.peer]
  local username = ctx.players:get(pid).username
  local reason = event.reason or 'left'
  self:emit(app.net.events.chat, {message = '{white}' .. username .. ' has left (' .. reason .. ')'})
  self:emit(app.net.events.leave, {id = pid, reason = reason})
  self.peerToPlayer[event.peer] = nil
  event.peer:disconnect_now()
  if username == ctx.owner then
    ctx.event:emit('game.quit')
  end
end

function NetServer:send(msg, peer, data)
  self.outStream:clear()
  self:pack(msg, data)
  peer:send(tostring(self.outStream))
end

function NetServer:emit(evt, data)
  if not self.host then return end
  local buffer = self.signatures[evt].important and self.importantEventBuffer or self.eventBuffer
  table.insert(buffer, {evt, data})
  ctx.event:emit(evt, data)
end

function NetServer:sync()
  if not self.host then return end

  if #self.importantEventBuffer > 0 then
    self.outStream:clear()
    while #self.importantEventBuffer > 0 do
      self:pack(unpack(self.importantEventBuffer[1]))
      table.remove(self.importantEventBuffer, 1)
    end

    self.host:broadcast(tostring(self.outStream), 0, 'reliable')
  end

  if #self.eventBuffer > 0 then
    self.outStream:clear()
    while #self.eventBuffer > 0 do
      self:pack(unpack(self.eventBuffer[1]))
      table.remove(self.eventBuffer, 1)
    end

    self.host:broadcast(tostring(self.outStream), 1, 'unreliable')
  end
end

function NetServer:snapshot(peer)
  local players = {}
  for id = 1, ctx.players.max do
    local p = ctx.players:get(id)
    if #p.username > 0 and id ~= self.peerToPlayer[peer] then
      table.insert(players, {
        id = id,
        username = p.username,
        class = p.class and p.class.id or 0,
        team = p.team or 0,
      })
    end
  end
  self:send(app.net.messages.snapshot, peer, {tick = tick, map = 'testArena', ['players'] = players})
end

function NetServer:nextPlayerId()
  for i = 1, ctx.players.max do
    if #ctx.players:get(i).username == 0 then return i end
  end
end

return NetServer
