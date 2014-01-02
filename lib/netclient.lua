NetClient = extend(Net)

NetClient.signatures = {}
NetClient.signatures[msgJoin] = {{'username', 'string'}}
NetClient.signatures[msgLeave] = {}
NetClient.signatures[msgClass] = {{'class', '4bits'}, {'team', '1bit'}}
NetClient.signatures[msgInput] = {
  {'tick', '16bits'},
  {'w', 'bool'}, {'a', 'bool'}, {'s', 'bool'}, {'d', 'bool'},
  {'mx', '12bits'}, {'my', '12bits'}, {'l', 'bool'}, {'r', 'bool'},
  {'weapon', '3bits'}, {'skill', '3bits'}, {'reload', 'bool'}
}
NetClient.signatures[msgChat] = {{'message', 'string'}}

NetClient.receive = {}
NetClient.receive['default'] = function(self, event) ovw.event:emit(event.msg, event.data) end

NetClient.receive[msgJoin] = function(self, event)
  myId = event.data.id
  setmetatable(ovw.players:get(myId), {__index = PlayerMain})
end

NetClient.receive[msgSnapshot] = function(self, event)
  tick = event.data.tick
  --ovw.map:load(event.data.map)
  for i = 1, #event.data.players do
    local p = event.data.players[i]
    if p.class > 0 then
      ovw.players:activate(p.id)
      ovw.players:setClass(p.id, p.class, p.team)
    end
  end
end

function NetClient:init()
  self.other = NetServer
  self:connectTo(serverIp, 6061)
  self.messageBuffer = {}

  ovw.event:on(evtJoin, self, function(self, data)
    ovw.players:get(data.id).username = data.username
  end)
  
  ovw.event:on(evtSync, self, function(self, data)
    local p = ovw.players:get(data.id)
    p:trace(data)
  end)

  Net.init(self)
end

function NetClient:connect(event)
  self.server = event.peer
  self:send(msgJoin, {username = username})
end

function NetClient:disconnect(event)
  Overwatch:remove(ovw)
  Overwatch:add(Menu)
end

function NetClient:send(msg, data)
  if not self.server then return end
  
  self.outStream:clear()
  self:pack(msg, data)
  self.server:send(tostring(self.outStream))
end

function NetClient:buffer(msg, data)
  table.insert(self.messageBuffer, {msg, data})
end

function NetClient:sync()
  if #self.messageBuffer == 0 then return end
  
  self.outStream:clear()
  
  while #self.messageBuffer > 0 do
    self:pack(unpack(self.messageBuffer[1]))
    table.remove(self.messageBuffer, 1)
  end
  
  self.server:send(tostring(self.outStream))
end

NetClient.emit = f.empty