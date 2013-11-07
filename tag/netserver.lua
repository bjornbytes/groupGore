NetServer = {}

NetServer.signatures = {
	outbound = {
		[Net.msgJoin] = {{'id', '4bits'}},
		[Net.msgClass] = {{'id', '4bits'}, {'class', '4bits'}, {'team', '1bit'}}
	}
}

NetServer.receive = {}

NetServer.receive[Net.msgJoin] = function(self, data, peer)
	local id = peer:index()
	self.clients[id] = {}
	self:send(Net.msgJoin, peer, {id = id})
end

NetServer.receive[Net.msgClass] = function(self, data, peer)
	self:broadcast(Net.msgClass, {
		id = peer:index(),
		class = data.class,
		team = data.team
	})
end

NetServer.receive[Net.msgSync] = function(self, data, peer)
	table.print(data.events)
end

function NetServer:activate()
	self:listen(6061)
	self.clients = {}
end

function NetServer:sync()
	local data = {}

	local needsSync = function(p) return p.active and p.sync and table.count(p.syncBuffer) > 0 end
	Players:with(needsSync, function(p)
		for _, s in ipairs(p:sync()) do data[#data + 1] = s end
	end)

	if #data > 0 then self:broadcast(Net.msgSync, data) end
end

function NetServer:writeEvents(events)
  Net:write(#events, 4)
  
  local sigs = {
    kill = {},
    assist = {},
    death = {{4, 'killer'}},
    spawn = {},
    hurt = {{4, 'from'}, {'f', 'amount'}},
    fire = {{3, 'slot'}},
    skill = {{3, 'slot'}}
  }
  
  for i = 1, #events do
    local event = events[i].e
    Net:write(Player.events[event], 4)
    for _, sig in pairs(sigs[event]) do
      Net:write(events[i].args[sig[2]], sig[1])
    end
  end
  
  return self
end

NetServer.messageHandlers = {
  [Net.msgJoin] = function(self, ip, port, stream)
    local name, listen = stream:read('', 16)
    local ct = 0
    table.iwith(self.clients, function() ct = ct + 1 end)
    local client = {
      id = ct + 1,
      ip = ip,
      port = listen,
      name = name,
      ping = 0,
      pingTime = -1
    }
    self.clients[client.id] = client
    self.clientsByIp[ip .. port] = client
    
    Net:begin(Net.msgJoin)
       :write(client.id, 4)
       :write(tick, 16)
       :write(table.count(self.clients) - 1, 4)
       
    for i = 1, 16 do
      if self.clients[i] and i ~= client.id then
        local p = Players:get(i)
        if not p.active then
          Net:write(p.id, 4)
             :write(self.clients[p.id].name)
             :write(0, 4)
             :write(0, 1)
        else
          Net:write(p.id, 4)
             :write(self.clients[p.id].name)
             :write(p.class.id, 4)
             :write(p.team, 1)
             :write(p.x, 16)
             :write(p.y, 16)
        end
      end
    end
    
    Net:send(client.id)
    
    Net:begin(Net.msgJoin)
       :write(client.id, 4)
       :write(client.name)
       :send(self.clients, client.id)
  end,
  
  [Net.msgClass] = function(self, client, stream)
    local class, team = stream:read(4, 1)
    if not Players:get(client.id).active then
      Players:activate(client.id, 'server', class, team)
    else
      local p = Players:get(client.id)
      p.class, p.team = class, team
    end
    
    Net:begin(Net.msgClass)
       :write(client.id, 4)
       :write(class, 4)
       :write(team, 1)
       :send(self.clients)
  end,
  
  [Net.msgSync] = function(self, client, stream)
    local ct, ticks = stream:read(4, 6)
    local data = {}
    local p = Players:get(client.id)
    for _ = 1, ticks do
      local t = stream:read(16)
      local w, a, s, d, mx, my, l, r, wep, skl, rel = stream:read(1, 1, 1, 1, 16, 16, 1, 1, 3, 3, 1)
      table.insert(data, {
        tick = t,
        input = {
          wasd = {
            w = w > 0,
            a = a > 0,
            s = s > 0,
            d = d > 0
          },
          mouse = {
            x = mx,
            y = my,
            l = l > 0,
            r = r > 0
          },
          slot = {
            weapon = wep,
            skill = skl,
            reload = rel > 0
          }
        }
      })
    end
		p:trace(data)
  end
}
