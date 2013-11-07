NetServer = {}

NetServer.signatures = {
	outbound = {
		[Net.msgJoin] = {{'id', '4bits'}},
		[Net.msgClass] = {{'id', '4bits'}, {'class', '4bits'}, {'team', '1bit'}},
		[Net.msgSync] = {{'updates', {
		  {'tick', '16bits'},
			{'id', '4bits'},
			{'x', '16bits'},
			{'y', '16bits'},
			{'angle', '16bits'}
		}}},
		[Net.msgSnapshot] = {
			{'tick', '16bits'},
			{'map', 'string'},
			{'clients', {
				{'id', '4bits'},
				{'username', 'string'},
				{'class', '4bits'},
				{'team', '1bit'},
			}},
		}
	}
}

NetServer.receive = {}

NetServer.receive[Net.msgJoin] = function(self, data, peer)
	local id = peer:index()
	self.clients[id] = {
		username = data.username
	}
	self:send(Net.msgJoin, peer, {id = id})
	self:sendSnapshot(peer)
end

NetServer.receive[Net.msgClass] = function(self, data, peer)
	local id = peer:index()

	if not Players:get(id).active then
		Players:activate(id, 'server', data.class, data.team)
	else
		local p = Players:get(id)
		p.class, p.team = data.class, data.team
	end
	
	self:broadcast(Net.msgClass, {
		id = peer:index(),
		class = data.class,
		team = data.team
	})
end

NetServer.receive[Net.msgSync] = function(self, data, peer)
	local trace = {}

	for _, update in ipairs(data.updates) do
		table.insert(trace, {
			tick = update.tick,
			input = {
				wasd = {
					w = update.w > 0,
					a = update.a > 0,
					s = update.s > 0,
					d = update.d > 0
				},
				mouse = {
					x = update.mx,
					y = update.my,
					l = update.l > 0,
					r = update.r > 0
				},
				slot = {
					weapon = update.wep,
					skill = update.skl,
					reload = update.rel > 0
				}
			}
		})
	end

	Players:get(peer:index()):trace(trace)
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

	if #data > 0 then self:broadcast(Net.msgSync, {updates = data}) end
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

function NetServer:sendSnapshot(peer)
	local data = {
		tick = tick,
		map = 'jungleCarnage',
		clients = {}
	}

	for i = 1, #self.clients do
		if self.clients[i] and i ~= peer:index() then
			local p = Players:get(i)
			data.clients[#data.clients + 1] = {
				id = i,
				username = self.clients[i].username,
				class = p.class and p.class.id or 0,
				team = p.team or 0,
			}
		end
	end

	self:send(Net.msgSnapshot, peer, data)
end
