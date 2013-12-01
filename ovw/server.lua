Server = class()

Server.tag = 'server'

function Server:load()
  self.event = Event()
  self.collision = Collision()
  self.players = Players()
  self.spells = Spells()
  self.net = NetServer()
  self.map = Map()

  for i = 1, 8 do
    local p = self.players:get(i)
    setmetatable(p, {__index = PlayerRobot})
    self.players:setClass(i, 1, i % 2)
    p.x = p.x - 20 + (10 * i) 
  end
end

function Server:update()
  self.net:update()
  self.players:update()
  self.spells:update()
end

function Server:sync()
  self.net:sync()
end

function Server:quit()
	if self.net.host then
		for i = 1, 16 do
			if self.net.host:get_peer(i) then self.net.host:get_peer(i):disconnect_now() end
		end
	end
end
