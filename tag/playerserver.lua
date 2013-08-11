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
  
  self.syncBuffer = {}
  
  Player.activate(self)
end

function PlayerServer:deactivate()
  self.input = nil
  
  Player.deactivate(self)
end

function PlayerServer:update()
  self:buff()
  self:move()
  self:turn()
  self:slot()
end

function PlayerServer:sync()
  --
end