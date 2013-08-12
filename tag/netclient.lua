NetClient = {}

function NetClient:activate()
  Udp:listen(0)
  local _, port = Udp.udp:getsockname()
  
  self.clients = {}
  
  Net:begin(Net.msgJoin)
     :write(username)
     :write(port, 16)
     :send()
  
  while not myId do
    Net:update()
  end
end

function NetClient:update()
  Udp:receive(function(data, ip, port)
    local stream = Stream.create(data)
    local id = stream:read(4)
    self.messageHandlers[id](self, stream)
  end)
end

function NetClient:send()
  assert(self.message)
  self.message:write('')
  Udp:send(self.message, serverIp, serverPort)
  self.message = nil
end

NetClient.messageHandlers = {
  [Net.msgCmd] = function(self, stream)
    local str = stream:read('')
    loadstring(str)()
  end,
  
  [Net.msgJoin] = function(self, stream)
    if not myId then
      myId, tick = stream:read(4, 16)
      local ct = stream:read(4)
      
      Map:load('jungleCarnage')
      
      for i = 1, ct do
        local id, name, class, team = stream:read(4, '', 4, 1)
        
        self.clients[id] = {
          id = id,
          name = name
        }
        
        if class > 0 then
          Players:activate(id, 'dummy', class, team)
          local p = Players:get(id)
          p.x, p.y = stream:read(16, 16)
        end
      end
    else
      local id, name = stream:read(4, '')
      print('new player ' .. name)
      self.clients[id] = {
        id = id,
        name = name
      }
    end
  end,
  
  [Net.msgLeave] = function(self, stream)
    local id = stream:read(4)
    Players:deactivate(id)
    self.clients[id] = nil
  end,
  
  [Net.msgClass] = function(self, stream)
    local id, class, team = stream:read(4, 4, 1)
    if not Players:get(id).active then
      local tag = id == myId and 'main' or 'dummy'
      Players:activate(id, tag, class, team)
    else
      Players:setClass(id, class, team)
    end
  end,
  
  [Net.msgSync] = function(self, stream)
    local ct = stream:read(4)
    for _ = 1, ct do
      local id, x, y, angle = stream:read(4, 16, 16, 9)
      local p = Players:get(id)
      if math.distance(p.x, p.y, x, y) > 64 then
        p.x = x
        p.y = y 
      else
        p.x = math.lerp(p.x, x, .5)
        p.y = math.lerp(p.y, y, .5)
      end
      CollisionOvw:refreshPlayer(p)
      p.angle = math.anglerp(p.angle, math.rad(angle), .5)
    end
  end,
  
  [Net.msgDie] = function(self, stream)
    local id = stream:read(4)
    Players:with(id, f.ego('die'))
  end,
  
  [Net.msgRespawn] = function(self, stream)
    local id = stream:read(4)
    Players:with(id, f.ego('respawn'))
  end,
  
  [Net.msgSpell] = function(self, stream)
    local owner, kind = stream:read(4, 6)
    Players:get(owner):spell(kind)
  end
}