Server = {}

function Server:update()
  --
end

function Server:sync()
  --
end

function Server.net(data, ip, port)
  --
end

Udp:listen(6061)
love.handlers['net'] = Server.net