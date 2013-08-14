NetServer = {}

function NetServer:activate()
  Udp:listen(6061)
  
  self.clients = {}
  self.clientsByIp = {}
end

function NetServer:update()
  Udp:receive(function(data, ip, port)
    local stream = Stream.create(data)
    local id, client = stream:read(4), self:lookup(ip, port)
    
    if not client and id == Net.msgJoin then
      self.messageHandlers[id](self, ip, port, stream)
    else
      self.messageHandlers[id](self, self:lookup(ip, port), stream)
    end
  end)
  
  for id, client in pairs(self.clients) do
    local t = love.timer.getMicroTime()
    if client.pingTime > 0 and t - client.pingTime > 1 then
      self:removeClient(client)
    elseif client.pingTime < 0 and client.pingTime + t > 1 then
      Net:begin(Net.msgPing)
         :write(tick, 16)
         :send(client.id)
      
      client.pingTime = t
    end
  end
end

function NetServer:send(clients, except)
  self.message:write('')
  if type(clients) == 'table' then
    for id, client in pairs(clients) do
      if id ~= except then
        Udp:send(self.message, client.ip, client.port)
      end
    end
  else
    local id = clients
    Udp:send(self.message, self.clients[id].ip, self.clients[id].port)
  end
  self.message = nil
end

function NetServer:lookup(ip, port)
  return self.clientsByIp[ip .. port]
end

function NetServer:removeClient(client)
  for k, v in pairs(self.clientsByIp) do
    if v == client then self.clientsByIp[k] = nil break end
  end
  if Players:get(client.id).active then
    Players:deactivate(client.id)
  end
  Net:begin(Net.msgLeave)
     :write(client.id, 4)
     :send(self.clients, client.id)
     
  self.clients[client.id] = nil
end

NetServer.messageHandlers = {
  [Net.msgCmd] = function(self, client, stream)
    local str = stream:read('')
    loadstring(str)()
    Net:begin(Net.msgCmd)
       :write(str)
       :send(Net.clients)
  end,
  
  [Net.msgPing] = function(self, client, stream)
    local t = love.timer.getMicroTime()
    client.ping = math.floor((t - client.pingTime) * 1000 + .5)
    client.pingTime = -t
  end,
  
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
  
  [Net.msgLeave] = NetServer.removeClient,
  
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