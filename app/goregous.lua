local Goregous = {}

Goregous.mock = true

local function explode(line)
  local res = {}
  while true do
    local pos = line:find(',')
    if not pos then break end
    table.insert(res, line:sub(1, pos))
    line = line:sub(pos + 1)
  end

  if #line > 0 then table.insert(res, line) end

  return res
end

function Goregous:getConnection()
	if self.created then return self.socket end

	self.socket = (require('socket')).tcp()
	self.socket:settimeout(10)
	local ip = table.has(arg, 'local') and '127.0.0.1' or ''
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

function Goregous:login(username, password)
  if self.mock then return true end
  if not self:getConnection() then return false end

  self:send({'login', username})

  local response = self.socket:receive('*l')

  if response == 'ok' then return true end

  return false
end

function Goregous:createServer()
  if self.mock then return true end
  if not self:getConnection() then return false end

  self:send({'createServer'})

  local response = self.socket:receive('*l')

  if response == 'ok' then return true end

  return false
end

function Goregous:listServers()
  if self.mock then return {} end
  if not self:getConnection() then return false end

  self:send({'listServers'})

  local count = self.socket:receive('*l')

  local servers = {}

  for i = 1, count do
    local line = self.socket:receive('*l')
    local data = explode(line)
    table.insert(servers, {name = data[1], ip = data[2]})
  end

  return servers
end

return Goregous
