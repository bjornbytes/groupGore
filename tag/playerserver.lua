PlayerServer = {}
setmetatable(PlayerServer, {__index = Player})

function PlayerServer:activate()
  self.input = {}
  
  self.input.w = false
  self.input.a = false
  self.input.s = false
  self.input.d = false
  
  self.input.mx = 0
  self.input.my = 0
  self.input.l = false
  self.input.r = false
  
  self.input.wep = 1
  self.input.skl = 3
  self.input.rel = false
    
  Player.activate(self)
end

function PlayerServer:deactivate()
  self.input = nil
  
  Player.deactivate(self)
end

function PlayerServer:update()
  local prevx, prevy, prevangle = self.x, self.y, self.angle
  self:time()
  self:buff()
  self:move()
  self:turn()
  self:slot()
  if self.x ~= prevx or self.y ~= prevy or self.angle ~= prevangle then
    Net:emit(evtSync, {
      id = self.id,
      tick = tick,
      x = math.floor(self.x + .5),
      y = math.floor(self.y + .5),
      angle = math.floor(((math.deg(self.angle) + 360) % 360) + .5)
    })
  end
end

function PlayerServer:time()
  self.ded = timer.rot(self.ded, function() Net:emit(evtSpawn, {id = self.id}) end)
  if self.ded == 0 then self.ded = false end
end

function PlayerServer:spell(kind)
  Player.spell(self, kind)
end
