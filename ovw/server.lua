Server = extend(Overwatch)

Server.tag = 'server'

function Server:init()
  self.event = Event()
  self.collision = Collision()
  
  self.players = self:addComponent(Players)
  self.spells = self:addComponent(Spells)
  self.buffs = self:addComponent(Buffs)
  self.net = self:addComponent(NetServer, {priority = 2})
  self.map = self:addComponent(Map)
  
  self:bindComponents()

  for i = 1, 0 do
    local p = self.players:get(i)
    setmetatable(p, {__index = PlayerRobot})
    self.players:setClass(i, 1, i % 2)
    p.x = p.x - 20 + (10 * i) 
  end
end

function Server:quit()
  if self.net.host then
    for i = 1, 16 do
      if self.net.host:get_peer(i) then self.net.host:get_peer(i):disconnect_now() end
    end
  end
  
  gorgeous:send(gorgeous.msgServerDelete)
end
