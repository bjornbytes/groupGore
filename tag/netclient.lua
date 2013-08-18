NetClient = {}

function NetClient:activate()
  Udp:listen(0)
  local _, port = Udp.udp:getsockname()
  
  self.clients = {}
  self.lastMessage = tick
  
  Net:begin(Net.msgJoin)
     :write(username)
     :write(port, 16)
     :send()
  
  timer.start()
  while not myId do
    Net:update()
    if timer.delta() > 2 then
      print('Unable to connect to server')
      Overwatch:unload()
      Overwatch = Menu
      Overwatch:load()
      return
    end
  end
end

function NetClient:update()
  Udp:receive(function(data, ip, port)
    local stream = Stream.create(data)
    local id = stream:read(4)
    self.messageHandlers[id](self, stream)
    self.lastMessage = tick
  end)
  if tick - self.lastMessage > 3 / tickRate then
    print('Lost connection to server')
    Overwatch:unload()
    Overwatch = Menu
    Overwatch:load()
  end
end

function NetClient:send()
  assert(self.message)
  self.message:write('')
  Udp:send(self.message, serverIp, serverPort)
  self.message = nil
end

function NetClient:readEvents(id, stream)
  local events = {}
  local ct = stream:read(4)
  local sigs = {
    kill = {},
    assist = {},
    death = {{4, 'killer'}},
    spawn = {},
    hurt = {{4, 'from'}, {'f', 'amount'}},
    fire = {{3, 'slot'}},
    skill = {{3, 'slot'}}
  }
  for _ = 1, ct do
    local e = Player.events[stream:read(4)]
    local args = {}
    for _, sig in pairs(sigs[e]) do
      args[sig[2]] = stream:read(sig[1])
      if sig[1] == 'f' then args[sig[2]] = tonumber(args[sig[2]]) end
    end
    table.insert(events, {
      e = e,
      args = args
    })
  end
  return events
end

NetClient.messageHandlers = {
  [Net.msgCmd] = function(self, stream)
    local str = stream:read('')
    loadstring(str)()
  end,
  
  [Net.msgPing] = function(self, stream)
    local t = stream:read(16)
    Net:begin(Net.msgPing)
       :send()
  end,
  
  [Net.msgJoin] = function(self, stream)
    if not myId then
      myId, tick = stream:read(4, 16)
      local ct = stream:read(4)
      
      Map:load('jungleCarnage')
      
      self.lastMessage = tick
      
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
      
      tickDelta = timer.delta()
      love.timer.step()
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
    if id == 0 then
      print('Server shut down')
      Overwatch:unload()
      Overwatch = Menu
      Overwatch:load()
    else
      Players:deactivate(id)
      self.clients[id] = nil
    end
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
    local players = stream:read(4)
    for _ = 1, players do
      local id, ticks = stream:read(4, 6)
      local data = {}
      local p = Players:get(id)
      for _ = 1, ticks do
        local t, x, y, angle = stream:read(16, 16, 16, 9)
        local events = self:readEvents(p.id, stream)
        table.insert(data, {
          tick = t,
          x = x,
          y = y,
          events = events
        })
        if id ~= myId then data[#data].angle = math.rad(angle) end
      end
      p:trace(data)
      CollisionOvw:refreshPlayer(p)
    end
  end
}