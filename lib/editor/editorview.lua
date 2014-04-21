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

  if not love.keyboard.isDown('lctrl') then
    if love.keyboard.isDown('w') then
      self.yVel = math.lerp(self.yVel, -self.maxSpeed, 10 * tickRate)
    elseif love.keyboard.isDown('s') then
      self.yVel = math.lerp(self.yVel, self.maxSpeed, 10 * tickRate)
    else
      self.yVel = math.lerp(self.yVel, 0, .1)
    end
    
    if love.keyboard.isDown('a') then
      self.xVel = math.lerp(self.xVel, -self.maxSpeed, 10 * tickRate)
    elseif love.keyboard.isDown('d') then
      self.xVel = math.lerp(self.xVel, self.maxSpeed, 10 * tickRate)
    else
      self.xVel = math.lerp(self.xVel, 0, .1)
    end
  end

  self.x = self.x + (self.xVel / (self.targetScale ^ 0.5))
  self.y = self.y + (self.yVel / (self.targetScale ^ 0.5))
  
  local prevw, prevh = self.w, self.h
  local xf, yf = love.mouse.getX() / love.graphics.getWidth(), love.mouse.getY() / love.graphics.getHeight()
  self.scale = math.round(math.lerp(self.scale, self.targetScale, 10 * tickRate) / .01) * .01
  self.w = love.graphics.getWidth() / self.scale
  self.h = love.graphics.getHeight() / self.scale
  self.x = self.x + (prevw - self.w) * xf
  self.y = self.y + (prevh - self.h) * yf
end

function EditorView:draw()
  View.draw(self)
end

function EditorView:mousepressed(x, y, button)
  if button == 'wu' then
    self.targetScale = math.min(self.targetScale + .2, 4)
  elseif button == 'wd' then
    self.targetScale = math.max(self.targetScale - .2, .2)
  end
end

function EditorView:transform(x, y)
  return x / self.scale + self.x, y / self.scale + self.y
end

EditorView.contain = f.empty
