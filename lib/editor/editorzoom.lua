require('lib/view')

EditorView = extend(View)

function EditorView:init()
  self.targetScale = 1
  
  self.x = 0
  self.y = 0
  self.xVel = 0
  self.yVel = 0
  self.maxSpeed = 20
  
  View.init(self)
end

function EditorView:update()
  View.update(self)

  if love.keyboard.isDown('w') then
    self.yVel = math.lerp(self.yVel, -self.maxSpeed, .25)
  elseif love.keyboard.isDown('s') then
    self.yVel = math.lerp(self.yVel, self.maxSpeed, .25)
  else
    self.yVel = math.lerp(self.yVel, 0, .1)
  end
  
  if love.keyboard.isDown('a') then
    self.xVel = math.lerp(self.xVel, -self.maxSpeed, .25)
  elseif love.keyboard.isDown('d') then
    self.xVel = math.lerp(self.xVel, self.maxSpeed, .25)
  else
    self.xVel = math.lerp(self.xVel, 0, .1)
  end

  self.x = self.x + (self.xVel / (self.targetScale / 1.5))
  self.y = self.y + (self.yVel / (self.targetScale / 1.5))
  
  local prevw, prevh = self.w, self.h
  local xf, yf = love.mouse.getX() / love.window.getWidth(), love.mouse.getY() / love.window.getHeight()
  self.scale = math.round(math.lerp(self.scale, self.targetScale, .25) / .01) * .01
  self.w = love.window.getWidth() / self.scale
  self.h = love.window.getHeight() / self.scale
  self.x = self.x + (prevw - self.w) * xf
  self.y = self.y + (prevh - self.h) * yf
  
  if self.x < 0 then self.x = 0 self.xVel = 0 end
  if self.y < 0 then self.y = 0 self.yVel = 0 end
  if self.x + self.w > ovw.map.width then self.x = ovw.map.width - self.w self.xVel = 0 end
  if self.y + self.h > ovw.map.height then self.y = ovw.map.height - self.h self.yVel = 0 end
end

function EditorView:draw()
  View.draw(self)
end

function EditorView:mousepressed(x, y, button)
  if button == 'wu' then
    self.targetScale = math.min(self.targetScale + .2, 4)
  elseif button == 'wd' then
    self.targetScale = math.max(self.targetScale - .2, .6)
  end
end