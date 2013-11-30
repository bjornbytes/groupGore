NetServer = Net()

NetServer.signatures = {}
NetServer.signatures[evtJoin] = {{'id', '4bits'}, {'username', 'string'}}
NetServer.signatures[evtLeave] = {{'id', '4bits'}, {'reason', 'string'}}
NetServer.signatures[evtClass] = {{'id', '4bits'}, {'class', '4bits'}, {'team', '1bit'}}
NetServer.signatures[evtSync] = {
  {'id', '4bits'},
  {'tick', '16bits'},
  {'x', '12bits'},
  {'y', '12bits'},
  {'angle', '10bits'},
  {'health', '10bits'}
}
NetServer.signatures[evtFire] = {{'id', '4bits'}, {'slot', '3bits'}}
NetServer.signatures[evtDamage] = {{'id', '4bits'}, {'amount', 'string'}, {'from', '4bits'}}
NetServer.signatures[evtDead] = {{'id', '4bits'}}
NetServer.signatures[evtSpawn] = {{'id', '4bits'}}
NetServer.signatures[msgJoin] = {{'id', '4bits'}}
NetServer.signatures[msgSnapshot] = {
  {'tick', '16bits'},
  {'map', 'string'},
  {'players', {{'id', '4bits'}, {'username', 'string'}, {'class', '4bits'}, {'team', '1bit'}}}
}

NetServer.receive = {}
NetServer.receive['default'] = f.empty

NetServer.receive[msgJoin] = function(self, event)
  self.clients[event.pid].username = event.data.username
  self:send(msgJoin, event.peer, {id = event.pid})
  self:emit(evtJoin, {id = event.pid, username = event.data.username})
  self:snapshot(event.peer)
end

NetServer.receive[msgLeave] = function(self, event)
  self:emit(evtLeave, {id = event.pid, reason = 'left'})
  event.peer:disconnect_now()
end

NetServer.receive[msgClass] = function(self, event)
  self:emit(evtClass, {id = event.pid, class = event.data.class, team = event.data.team})
end

NetServer.receive[msgInput] = function(self, event)
  local p = ovw.players:get(event.pid)
  local t = event.data.tick
  event.data.tick = nil
  for i = t, tick do
    local state = table.copy(ovw.players.history[p.id][i - 1])
    if state then
      local dst = (i == tick) and p or ovw.players.history[p.id][i]
      state.input = event.data
      dst.input = event.data
      state:move()
      state:turn()
    end
  end
end

function NetServer:init()
  self.other = NetClient

  self:listen(6061)
  self.clients = {}
  self.eventBuffer = {}
  
  ovw.event:on(evtJoin, self, function(self, data)
    print(data.username .. ' has joined!')
  end)
  
  ovw.event:on(evtLeave, self, function(self, data)
    print('Player ' .. data.id .. ' has left!')
  end)

  Net.init(self)
end

function NetServer:connect(event)
  self.clients[event.pid] = {id = event.pid}
end

function NetServer:send(msg, peer, data)
  self.outStream:clear()
  self:pack(msg, data)
  peer:send(tostring(self.outStream))
end

function NetServer:emit(evt, data)
  table.insert(self.eventBuffer, {evt, data})
  ovw.event:emit(evt, data)
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
  table.with(ovw.players.active, function(id)
    print(id)
    if id ~= peer:index() then
      local p = ovw.players:get(id)
      table.insert(players, {
        id = id,
        username = self.clients[id] and self.clients[id].username or 'robot',
        class = p.active and 1 or 0,
        team = p.team or 0,
      })
    end
  end)
  self:send(msgSnapshot, peer, {tick = tick, map = 'jungleCarnage', ['players'] = players})
end
