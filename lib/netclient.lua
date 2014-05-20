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
  --delta = {{'w', 'a', 's', 'd'}, 'mx', 'my', 'weapon', 'l', 'r', 'skill', 'reload'}
}
NetClient.signatures[msgChat] = {{'message', 'string'}}

NetClient.receive = {}
NetClient.receive['default'] = function(self, event) ctx.event:emit(event.msg, event.data) end

NetClient.receive[msgJoin] = function(self, event)
  ctx.id = event.data.id
  setmetatable(ctx.players:get(ctx.id), {__index = PlayerMain})
end

NetClient.receive[msgSnapshot] = function(self, event)
  --tick = event.data.tick + math.round(self.server:round_trip_time() / 2 / 1000 / tickRate)
  tick = event.data.tick
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
    p:trace(data)
  end)

  Net.init(self)
end

function NetClient:connect(event)
  self.server = event.peer
  self:send(msgJoin, {username = username})
end

function NetClient:disconnect(event)
  ctx.id = nil
  Context:remove(ctx)
  Context:add(Menu)
end

function NetClient:send(msg, data)
  if not self.server then return end
  
  self.outStream:clear()
  self:pack(msg, data)
  self.server:send(tostring(self.outStream))
end

function NetClient:buffer(msg, data)
  --table.insert(self.messageBuffer, {msg, data})
  --self:sync()
  table.insert(self.messageBuffer, {msg, data, tick})
end

function NetClient:sync()
  if #self.messageBuffer == 0 then return end
  
  self.outStream:clear()
 
  while #self.messageBuffer > 0 and (tick - self.messageBuffer[1][3]) * tickRate >= .000 do
    local msg, data, tick = unpack(self.messageBuffer[1])
    self:pack(msg, data)
    table.remove(self.messageBuffer, 1)
  end
 
  local res = tostring(self.outStream)
  if #res > 0 then self.server:send(res) end
end

NetClient.emit = f.empty
