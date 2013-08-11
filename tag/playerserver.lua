PlayerServer = {}
setmetatable(PlayerServer, {__index = Player})

function PlayerServer:activate()
  self.input = {}
  
  self.input.wasd = {}
  self.input.wasd.w = false
  self.input.wasd.a = false
  self.input.wasd.s = false
  self.input.wasd.d = false
  
  self.input.mouse = {}
  self.input.mouse.x = 0
  self.input.mouse.y = 0
  self.input.mouse.l = false
  self.input.mouse.r = false
  
  self.input.slot = {}
  self.input.slot.weapon = 1
  self.input.slot.skill = 3
  self.input.slot.reload = false
  
  Player.activate(self)
end

function PlayerServer:deactivate()
  self.input = nil
  
  Player.deactivate(self)
end

function PlayerServer:update()
  self:time()
  self:buff()
  self:move()
  self:turn()
  self:slot()
  
  self:hurt(50 * tickRate)
end

function PlayerServer:sync()
  local ang = math.floor(math.deg(self.angle))
  if ang < 0 then ang = ang + 360 end
  Net:write(self.id, 4)
     :write(math.floor(self.x + .5), 16)
     :write(math.floor(self.y + .5), 16)
     :write(math.floor(ang), 9)
end

function PlayerServer:time()
  self.ded = timer.rot(self.ded, function() self:respawn() end)
  if self.ded == 0 then self.ded = false end
end

function PlayerServer:hurt(amount, from)
  if Player.hurt(self, amount, from) then
    if self.health <= 0 then self:die() end
  end
end

function PlayerServer:die()
  Player.die(self)
  Net:begin(Net.msgDie)
     :write(self.id, 4)
     :send(Net.clients)
end

function PlayerServer:respawn()
  Player.respawn(self)
  Net:begin(Net.msgRespawn)
     :write(self.id, 4)
     :send(Net.clients)
end