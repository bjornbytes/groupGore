Editor = class()

local function invoke(x, k, ...) return x.editor[k](x, ...) end

function Editor:load()
  self.view = View()
  self.map = Map()
  
  self.gridSize = 32
  
  self.x = 0
  self.y = 0
  self.xVel = 0
  self.yVel = 0
  self.maxSpeed = 20
  
  self.scale = self.view.scale
  self.scaleTargetX = 0
  self.scaleTargetY = 0
  
  self.dragging = nil
  self.dragOffsetX = 0
  self.dragOffsetY = 0
  
  self.grid = {
    depth = -10000,
    draw = function()
      love.graphics.setColor(255, 255, 255, 10)

      for i = .5, self.map.width, self.gridSize do
        love.graphics.line(i, 0, i, self.map.height)
      end

      for i = .5, self.map.height, self.gridSize do
        love.graphics.line(0, i, self.map.width, i)
      end

      table.each(self.map.props, function(p)
        love.graphics.setColor(0, 255, 255, self.dragging == p and 200 or 50)
        love.graphics.rectangle('line', invoke(p, 'boundingBox'))
      end)
    end
  }
  
  self.view:register(self.grid)
end

function Editor:update()
  if self.dragging then
    local x, y = self.dragging.x, self.dragging.y
    local tx = math.round((mouseX() - self.dragOffsetX) / self.gridSize) * self.gridSize
    local ty = math.round((mouseY() - self.dragOffsetY) / self.gridSize) * self.gridSize
    if x ~= tx or y ~= ty then
      invoke(self.dragging, 'dragTo', tx, ty)
    end
  end
  
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
    
  self.view:update()
  
  self.view.x = self.view.x + (self.xVel / (self.scale / 1.5))
  self.view.y = self.view.y + (self.yVel / (self.scale / 1.5))
  
  local prevw, prevh = self.view.w, self.view.h
  local xf, yf = love.mouse.getX() / love.window.getWidth(), love.mouse.getY() / love.window.getHeight()
  self.view.scale = math.round(math.lerp(self.view.scale, self.scale, .25) / .01) * .01
  self.view.w = love.window.getWidth() / self.view.scale
  self.view.h = love.window.getHeight() / self.view.scale
  self.view.x = self.view.x + (prevw - self.view.w) * xf
  self.view.y = self.view.y + (prevh - self.view.h) * yf
  
  if self.view.x < 0 then self.view.x = 0 self.xVel = 0 end
  if self.view.y < 0 then self.view.y = 0 self.yVel = 0 end
  if self.view.x + self.view.w > ovw.map.width then self.view.x = ovw.map.width - self.view.w self.xVel = 0 end
  if self.view.y + self.view.h > ovw.map.height then self.view.y = ovw.map.height - self.view.h self.yVel = 0 end
  
  self.map:update()
end

function Editor:draw()
  self.view:draw()
end

function Editor:mousepressed(x, y, button)
  if button == 'l' then
    table.each(self.map.props, function(p)
      local x, y, w, h = invoke(p, 'boundingBox')
      if math.inside(mouseX(), mouseY(), x, y, w, h) then
        self.dragging = p
        self.dragOffsetX = mouseX() - x
        self.dragOffsetY = mouseY() - y
      end
    end)
  elseif button == 'wu' then
    self.scale = math.min(self.scale + .2, 8)
  elseif button == 'wd' then
    self.scale = math.max(self.scale - .2, 1)
  end
end

function Editor:mousereleased(x, y, button)
  self.dragging = nil
end