local socket = require 'socket'

Udp = {}

function Udp:listen(port)
  assert(port)
  
  self.udp = socket.udp()
  self.udp:settimeout(0)
  self.udp:setsockname('*', port)
end

function Udp:send(data, ip, port)
  assert(self.udp)
  assert(data)
  assert(ip)
  assert(port)
  
  self.udp:sendto(tostring(data), ip, port)
end

function Udp:receive()
  assert(self.udp)
  
  repeat
    local data, ip, port = self.udp:receivefrom()
    if data then love.event.push('net', data, ip, port) end
  until not data
end