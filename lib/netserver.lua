NetServer = extend(Net)

NetServer.signatures = {}
NetServer.signatures[evtJoin] = {{'id', '4bits'}, {'username', 'string'}}
NetServer.signatures[evtLeave] = {{'id', '4bits'}, {'reason', 'string'}}
NetServer.signatures[evtClass] = {{'id', '4bits'}, {'class', '4bits'}, {'team', '1bit'}}
NetServer.signatures[evtSync] = {
  {'id', '4bits'},
  {'tick', '16bits'},
  {'ack', '16bits'},
  {'x', '12bits'},
  {'y', '12bits'},
  {'angle', '10bits'},
  {'health', '10bits'},
  {'shield', '10bits'},
  delta = {'x', 'y', 'angle', 'health', 'shield'}
}
NetServer.signatures[evtFire] = {{'id', '4bits'}, {'slot', '3bits'}}
NetServer.signatures[evtDamage] = {{'id', '4bits'}, {'amount', 'string'}, {'from', '4bits'}}
NetServer.signatures[evtDead] = {{'id', '4bits'}, {'kill', '4bits'}, {'assists', {{'id', '4bits'}}}}
NetServer.signatures[evtSpawn] = {{'id', '4bits'}}
NetServer.signatures[evtChat] = {{'message', 'string'}}
NetServer.signatures[msgJoin] = {{'id', '4bits'}}
NetServer.signatures[msgSnapshot] = {
  {'tick', '16bits'},
  {'map', 'string'},
  {'players', {{'id', '4bits'}, {'username', 'string'}, {'class', '4bits'}, {'team', '1bit'}}}
}

NetServer.receive = {}
NetServer.receive['default'] = f.empty

NetServer.receive[msgJoin] = function(self, event)
  local pid = self.peerToPlayer[event.peer]
  ctx.players:get(pid).username = event.data.username
  self:send(msgJoin, event.peer, {id = pid})
  self:emit(evtJoin, {id = pid, username = event.data.username})
  self:emit(evtChat, {message = '{white}' .. event.data.username .. ' has joined!'})
  self:snapshot(event.peer)
end

NetServer.receive[msgLeave] = function(self, event)
  local pid = self.peerToPlayer[event.peer]
  self:emit(evtChat, {message = '{white}' .. ctx.players:get(pid).username .. ' has left!'})
  self:emit(evtLeave, {id = pid, reason = 'left'})
  self.peerToPlayer[event.peer] = nil
  event.peer:disconnect_now()
end

NetServer.receive[msgClass] = function(self, event)
  self:emit(evtClass, {id = self.peerToPlayer[event.peer], class = event.data.class, team = event.data.team})
end

NetServer.receive[msgInput] = function(self, event)
  ctx.players:get(self.peerToPlayer[event.peer]):trace(event.data, event.peer:last_round_trip_time())
end

NetServer.receive[msgChat] = function(self, event)
  local pid = self.peerToPlayer[event.peer]
  local username = ctx.players:get(pid).username
  local color = ctx.players:get(pid).team == 0 and 'purple' or 'orange'
  self:emit(evtChat, {message = '{' .. color .. '}' .. username .. '{white}: ' .. event.data.message:gsub('god', 'light'):gsub('fuck', 'd\'arvit')})
end

function NetServer:init()
  self.other = NetClient

  self:listen(6061)
  self.peerToPlayer = {}
  self.eventBuffer = {}

  Net.init(self)
end

function NetServer:quit()
  if self.host then
    for i = 1, 16 do
      if self.host:get_peer(i) then self.host:get_peer(i):disconnect_now() end
    end
  end
end

function NetServer:connect(event)
  self.peerToPlayer[event.peer] = self:nextPlayerId()
end

function NetServer:send(msg, peer, data)
  self.outStream:clear()
  self:pack(msg, data)
  peer:send(tostring(self.outStream))
end

function NetServer:emit(evt, data)
  table.insert(self.eventBuffer, {evt, data})
  ctx.event:emit(evt, data)
end

function NetServer:sync()
  if #self.eventBuffer == 0 then return end
  
  self.outStream:clear()
  
  while #self.eventBuffer > 0 do
    self:pack(unpack(self.eventBuffer[1]))
    table.remove(self.eventBuffer, 1)
  end

  self.host:broadcast(tostring(self.outStream))
end

function NetServer:snapshot(peer)
  local players = {}
  for id = 1, 16 do
    local p = ctx.players:get(id)
    if #p.username > 0 and id ~= self.peerToPlayer[peer] then
      table.insert(players, {
        id = id,
        username = p.username,
        class = p.active and p.class.id or 0,
        team = p.team or 0,
      })
    end
  end
  self:send(msgSnapshot, peer, {tick = tick, map = 'testArena', ['players'] = players})
end

function NetServer:nextPlayerId()
  for i = 1, 16 do
    if #ctx.players:get(i).username == 0 then return i end
  end
end
