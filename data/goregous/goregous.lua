Goregous = class()

function Goregous:init()
  self.socket = (require('socket')).tcp()
  self.socket:settimeout(10)
  local ip = (env == 'local') and '127.0.0.1' or '67.0.161.178'
  local _, e = self.socket:connect(ip, 6060)
  if e then error('Can\'t connect to goregous') end
  self.socket:settimeout(0)
  self.messages = {}
end

function Goregous:update()
  while true do
    str = self.socket:receive('*l')
    if not str then break end
    local data = {}
    for word in string.gmatch(str, '([^,]+)') do
      table.insert(data, word)
    end
    table.insert(self.messages, data)
  end
end

function Goregous:quit()
  self.socket:close()
end

function Goregous:send(data)
  self.socket:send(table.concat(data, ',') .. '\n')
end