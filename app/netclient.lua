NetClient = extend(Net)

NetClient.signatures = {}
NetClient.signatures[msgJoin] = {{'username', 'string'}, important = true}
NetClient.signatures[msgLeave] = {important = true}
NetClient.signatures[msgClass] = {{'class', '4bits'}, {'team', '1bit'}, important = true}
NetClient.signatures[msgInput] = {
  {'tick', '16bits'},
  {'w', 'bool'}, {'a', 'bool'}, {'s', 'bool'}, {'d', 'bool'},
  {'x', '12bits'}, {'y', '12bits'}, {'l', 'bool'}, {'r', 'bool'},
  {'slot', '3bits'}, {'reload', 'bool'},
  delta = {{'w', 'a', 's', 'd'}, {'x', 'y'}, 'l', 'r', 'slot', 'reload'}
}
NetClient.signatures[msgChat] = {{'message', 'string'}, important = true}

NetClient.receive = {}
NetClient.receive['default'] = function(self, event) ctx.event:emit(event.msg, event.data) end

NetClient.receive[msgJoin] = function(self, event)
  ctx.id = event.data.id
  setmetatable(ctx.players:get(ctx.id), {__index = PlayerMain})
end

NetClient.receive[msgSnapshot] = function(self, event)
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
  self.other = NetServer
  self:connectTo(serverIp, 6061)
  self.messageBuffer = {}

  ctx.event:on(evtJoin, function(data)
    ctx.players:get(data.id).username = data.username
  end)

  ctx.event:on(evtSync, function(data)
    local p = ctx.players:get(data.id)
    if p and p.active then
      p:trace(data)
    end
  end)

  ctx.event:on('game.quit', function(data)
    self:quit()
  end)

  Net.init(self)
end

function NetClient:quit()
  self:send(msgLeave)
  self.host:flush()
  self.server:disconnect()
end

function NetClient:connect(event)
  self.server = event.peer
  self:send(msgJoin, {username = username})
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

  local channel = self.signatures[msg].important and 0 or 1
  local reliability = self.signatures[msg].important and 'reliable' or 'unreliable'
  self.server:send(tostring(self.outStream), channel, reliability)
end

NetClient.emit = f.empty
