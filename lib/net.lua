Net = class()

evtJoin  = 1
evtLeave = 2
evtClass = 3
evtSync = 4
evtFire = 5
evtDamage = 6
evtDead = 7
evtSpawn = 8

msgJoin  = 9
msgLeave = 10
msgSnapshot = 11
msgClass = 12
msgInput = 13

function Net:init()
	self.inStream = Stream()
	self.outStream = Stream()
end

function Net:listen(port)
	self.host = enet.host_create(port and '*:' .. port or nil)
end

function Net:connectTo(ip, port)
	if not self.host then self:listen() end
	self.host:connect(ip .. ':' .. port)
end

function Net:update()
	while true do
		local event = self.host:service()
		if not event then break end
		
		event.pid = event.peer:index()
		
		if event.type == 'receive' then
			self.inStream:clear()
			self.inStream.str = event.data

			repeat
				event.msg, event.data = self:unpack()
				;(self.receive[event.msg] or self.receive.default)(self, event)
			until not event.msg
		else
			f.exe(self[event.type], self, event)
		end
	end
end

function Net:pack(msg, data)
	self.outStream:write(msg, '4bits')
	local function halp(data, signature)
		for _, sig in ipairs(signature) do
			if type(sig[2]) == 'table' then
				self.outStream:write(#data[sig[1]], '4bits')
				for i = 1, #data[sig[1]] do halp(data[sig[1]][i], sig[2]) end
			else
				self.outStream:write(data[sig[1]], sig[2])
			end
		end
	end
	halp(data, self.signatures[msg])
end

function Net:unpack()
	local function halp(signature)
		local data = {}
		for _, sig in ipairs(signature) do
			if type(sig[2]) == 'table' then
				local ct = self.inStream:read('4bits')
				data[sig[1]] = {}
				for i = 1, ct do table.insert(data[sig[1]], halp(sig[2])) end
			else
				data[sig[1]] = self.inStream:read(sig[2])
			end
		end
		return data
	end
	local msg = self.inStream:read('4bits')
	if msg == 0 or not self.other.signatures[msg] then return false end
	return msg, halp(self.other.signatures[msg])
end