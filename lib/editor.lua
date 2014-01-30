Editor = class()

local function invoke(x, k, ...) return x.editor[k](x, ...) end

function Editor:load()
  self.view = View()
  self.map = Map()
  
  self.gridSize = 32
  self.findProp = false
  self.findPropX = 0
  self.findPropY = 0
  self.findPropDstX = 0
  self.findPropDstY = 0
  self.findPropStr = ''
  self.findPropPrev = 'wall'
  self.findPropPrevPrev = 'wall'
  
  self.x = 0
  self.y = 0
  self.xVel = 0
  self.yVel = 0
  self.maxSpeed = 20
  
  self.targetScale = self.view.scale
  
  self.dragging = nil
  self.dragOffsetX = 0
  self.dragOffsetY = 0
  
  self.scaling = nil
  self.scaleAnchor = nil
  self.scaleOriginX = 0
  self.scaleOriginY = 0
  self.scaleHandleX = 0
  self.scaleHandleY = 0
  
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
        love.graphics.setColor(0, 255, 255, (self.dragging == p or self.scaling == p) and 200 or 50)
        if self.scaling then
          local x, y, w, h = invoke(p, 'boundingBox')
          love.graphics.line(x, y, x + 16, y)
          love.graphics.line(x, y, x, y + 16)
          love.graphics.line(x + w - 16, y, x + w, y)
          love.graphics.line(x + w, y, x + w, y + 16)
          love.graphics.line(x, y + h - 16, x, y + h)
          love.graphics.line(x, y + h, x + 16, y + h)
          love.graphics.line(x + w - 16, y + h, x + w, y + h)
          love.graphics.line(x + w, y + h - 16, x + w, y + h)
        else
          love.graphics.rectangle('line', invoke(p, 'boundingBox'))
        end
      end)
    end
  }
  
  self.view:register(self.grid)

  self.gooey = Gooey()

  self.props = {}
  for _, v in ipairs(data.prop) do
    table.insert(self.props, v.code)
  end
  table.sort(self.props)
end

function Editor:update()
  if self.dragging then
    local x, y = self.dragging.x, self.dragging.y
    local tx, ty = self:snap(mouseX() - self.dragOffsetX, mouseY() - self.dragOffsetY)
    if x ~= tx or y ~= ty then
      invoke(self.dragging, 'dragTo', tx, ty)
    end
  end
  
  if self.scaling then
    local mx, my = mouseX(), mouseY()
    local winc, hinc = self:snap(mx - self.scaleOriginX, my - self.scaleOriginY)
    if true then
      local ox, oy = self.scaleAnchor[1] + (self.scaleAnchor[3] / 2), self.scaleAnchor[2] + (self.scaleAnchor[4] / 2)
      invoke(self.scaling, 'scale', self.scaleHandleX, self.scaleHandleY, winc, hinc, unpack(self.scaleAnchor))
    end
  end
  
  self.view:update()

  if not self.findProp then
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
  
    self.view.x = self.view.x + (self.xVel / (self.targetScale / 1.5))
    self.view.y = self.view.y + (self.yVel / (self.targetScale / 1.5))
  end
  
  local prevw, prevh = self.view.w, self.view.h
  local xf, yf = love.mouse.getX() / love.window.getWidth(), love.mouse.getY() / love.window.getHeight()
  self.view.scale = math.round(math.lerp(self.view.scale, self.targetScale, .25) / .01) * .01
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

  if self.findProp then
    self.gooey:font('aeroMatics', 2)
    love.graphics.setColor(0, 0, 0, 160)
    local w = math.max(160, love.graphics.getFont():getWidth(self.findPropStr))
    local h = (love.graphics.getFont():getHeight() + 4) * (#self.props + 1) + 6
    local x, y = self.findPropX + 10, self.findPropY + 10
    if x + w > love.window.getWidth() then x = love.window.getWidth() - w end
    if y + h > love.window.getHeight() then y = love.window.getHeight() - h end
    love.graphics.rectangle('fill', x, y, w, h)

    love.graphics.setColor(255, 255, 255, self.findPropStr == self.findPropPrev and 100 or 200)
    love.graphics.print(self.findPropStr, x + 4, y + 2)

    love.graphics.setColor(255, 255, 255, 80)
    local yy = y + love.graphics.getFont():getHeight() + 6
    love.graphics.line(x, yy, x + w, yy)
    yy = yy + 6
    for i = 1, #self.props do
      local p = self.props[i]
      love.graphics.print(p, x + 4, yy)
      yy = yy + love.graphics.getFont():getHeight() + 2
    end
  end
end

function Editor:keypressed(key)
  local handlers = {
    ['escape'] = function() love.event.push('quit') end,
    ['return'] = function()
      if not self.findProp then
        self.findProp = true
        self.findPropX = love.mouse.getX()
        self.findPropY = love.mouse.getY()
        self.findPropDstX, self.findPropDstY = self:snap(mouseX(), mouseY())
        self.findPropStr = self.findPropPrev

        self.xVel = 0
        self.yVel = 0
        return
      end

      if data.prop[self.findPropStr] then
        table.insert(ovw.map.props, ovw.map:initProp({
          kind = self.findPropStr,
          x = self.findPropDstX,
          y = self.findPropDstY,
          w = 64,
          h = 64,
          z = 64
        }))
        self.findPropPrevPrev = self.findPropStr
      end

      self.findProp = false
      self.findPropPrev = self.findPropPrevPrev
    end,
    ['backspace'] = function()
      if self.findPropStr == self.findPropPrev then self.findPropStr = ''
      else self.findPropStr = self.findPropStr:sub(1, -2) end
    end,
    ['delete'] = function()
      table.each(ovw.map.props, function(p)
        if math.inside(mouseX(), mouseY(), invoke(p, 'boundingBox')) then
          ovw.view:unregister(p)
          ovw.map.props = table.filter(ovw.map.props, function(prop) return p ~= prop end)
        end
      end)
    end,
    ['['] = function() self.gridSize = math.max(self.gridSize / 2, 8) end,
    [']'] = function() self.gridSize = math.min(self.gridSize * 2, 256) end
  }

  return f.exe(handlers[key])
end

function Editor:textinput(char)
  if self.findProp then
    if self.findPropStr == self.findPropPrev then self.findPropStr = '' self.findPropPrev = '' end
    self.findPropStr = self.findPropStr .. char
  end
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
  elseif button == 'r' then
    table.each(self.map.props, function(p)
      local x, y, w, h = invoke(p, 'boundingBox')
      if math.inside(mouseX(), mouseY(), x, y, w, h) then
        self.scaling = p
        self.scaleHandleX = mouseX() > x + (w / 2) and 1 or -1
        self.scaleHandleY = mouseY() > y + (h / 2) and 1 or -1
        self.scaleOriginX = mouseX()
        self.scaleOriginY = mouseY()
        self.scaleAnchor = {x, y, w, h}
      end
    end)
  elseif button == 'wu' then
    self.targetScale = math.min(self.targetScale + .2, 8)
  elseif button == 'wd' then
    self.targetScale = math.max(self.targetScale - .2, 1)
  end
end

function Editor:mousereleased(x, y, button)
  self.dragging = nil
  self.scaling = nil
end

function Editor:snap(x, y)
  if love.keyboard.isDown('lalt') then return x, y end
  return math.round(x / self.gridSize) * self.gridSize, math.round(y / self.gridSize) * self.gridSize
end