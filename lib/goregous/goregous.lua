Goregous = {}

function Goregous:getConnection()
	if self.created then return self.socket end

	self.socket = (require('socket')).tcp()
	self.socket:settimeout(10)
	local ip = '127.0.0.1'
	local _, e = self.socket:connect(ip, 6060)
	if e then self.socket = nil
	else self.socket:settimeout(5) end
	self.created = true
	return self.socket
end

function Goregous:send(data)
	if not self:getConnection() then return end
  self.socket:send(table.concat(data, ',') .. '\n')
end

function Goregous:patch(version, os)
	if not self:getConnection() then return false end

  self:send({'version', version, os})

  local bytes = tonumber(self.socket:receive('*l'))
  if bytes == 0 then return false end
  local code, data
  
  code = self.socket:receive(bytes)
  data = self.socket:receive(tonumber(self.socket:receive('*l')))

	return code, data
end

