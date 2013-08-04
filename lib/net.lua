local socket = require 'socket'

Udp = class()

function Udp:init(port, remoteIp, remotePort)
  self.remoteIp = remoteIp
  self.remotePort = remotePort
  self.udp = socket.udp()
  self.udp:settimeout(0)
  if port then self.udp:setsockname('*', port) end
  if self.remoteIp then self.udp:setpeername(remoteIp, remotePort) end
end

function Udp:send(data, ip, port)
  if not ip then return self.udp:send(tostring(data)) end
  self.udp:sendto(tostring(data), ip, port)
end

function Udp:receive()
  repeat
    local data, ip, port
    if self.remoteIp then data = self.udp:receive()
    else data, ip, port = self.udp:receivefrom() end
    if data and self.onmessage then self.onmessage(data, ip, port) end
  until not data
end