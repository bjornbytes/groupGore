NetClient = {}

NetClient.signatures = {
	outbound = {
		[Net.msgJoin] = {{'username', 'string'}},
		[Net.msgClass] = {{'class', '4bits'}, {'team', '1bit'}},
	}
}

NetClient.receive = {}
NetClient.receive[Net.msgJoin] = function(self, data, peer)
	myId = data.id
	Map:load('jungleCarnage')
end

NetClient.receive[Net.msgClass] = function(self, data, peer)
	if not Players:get(data.id).active then
		local tag = data.id == myId and 'main' or 'dummy'
		Players:activate(data.id, tag, data.class, data.team)
	else
		Players:setClass(data.id, data.class, data.team)
	end
end

function NetClient:connect(peer)
	self.server = peer
	self:send(Net.msgJoin, Net.server, {
		username = username
	})
end

function NetClient:activate()
  self:connectTo('localhost', 6061)
  local port = self.host:socket_get_address():match(':(%d+)')
	while not myId do
		self:update()
	end
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
  end,
  
  [Net.msgSync] = function(self, stream)
    local players = stream:read(4)
    for _ = 1, players do
      local id, ticks = stream:read(4, 6)
      local data = {}
      local p = Players:get(id)
      assert(p and p.trace, 'no trace for ' .. id)
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
