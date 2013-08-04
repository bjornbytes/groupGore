PlayerMain = {}
setmetatable(PlayerMain, {__index = Player})

function PlayerMain:activate()
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
  self.input.slot.reload = false
  
  Player.activate(self)
end

function PlayerMain:deactivate()
  self.input = nil
  
  Player.deactivate(self)
end

function PlayerMain:update()
  self:poll()
  self:move()
  self:turn()
  self:slot()
end

function PlayerMain:poll()
  local wasd, mouse, slot = self.input.wasd, self.input.mouse, self.input.slot
  
  wasd.w, wasd.a, wasd.s, wasd.d = love.keyboard.downs('w', 'a', 's', 'd')
  mouse.x, mouse.y = mouseX(), mouseY()
  slot.reload = love.keyboard.isDown('r')
end