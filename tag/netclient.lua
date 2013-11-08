NetClient = {}

NetClient.signatures = {
	outbound = {
		[Net.msgJoin] = {{'username', 'string'}},
		[Net.msgClass] = {{'class', '4bits'}, {'team', '1bit'}},
		[Net.msgSync] = {{'updates', {
			{'tick', '16bits'},
			{'w', '1bit'},
			{'a', '1bit'},
			{'s', '1bit'},
			{'d', '1bit'},
			{'mx', '16bits'},
			{'my', '16bits'},
			{'l', '1bit'},
			{'r', '1bit'},
			{'wep', '3bits'},
			{'skl', '3bits'},
			{'rel', '1bit'}
		}}},
		[Net.msgSnapshot] = {}
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

NetClient.receive[Net.msgSync] = function(self, data, peer)
	local playerUpdates = {}

	for _, update in ipairs(data.updates) do
		playerUpdates[update.id] = playerUpdates[update.id] or {}
		table.insert(playerUpdates[update.id], {
			tick = update.tick,
			x = update.x,
			y = update.y,
      angle = math.rad(update.angle)
		})
	end

	for id, data in pairs(playerUpdates) do
		Players:get(id):trace(data)
	end
end

NetClient.receive[Net.msgSnapshot] = function(self, data, peer)
	table.print(data)
	tick = data.tick
	Map:load(data.map)
	for _, client in ipairs(data.clients) do
		if client.class > 0 then
			Players:activate(client.id, 'dummy', client.class, client.team)
		end
	end
end

function NetClient:connect(peer)
	self.server = peer
	self:send(Net.msgJoin, Net.server, {
		username = username
	})
end

function NetClient:activate()
  self:connectTo(serverIp, 6061)
  local port = self.host:socket_get_address():match(':(%d+)')
	while not myId do
		self:update()
	end
end

function NetClient:sync()
	local p = Players:get(myId)
	if p and p.active and p.sync and table.count(p.syncBuffer) > 0 then
		self:send(Net.msgSync, Net.server, {updates = p:sync()})
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
