Editor = class()

local function invoke(x, k, ...) return x.editor[k](x, ...) end

function Editor:load()
  self.font = love.graphics.newFont('media/fonts/aeromatics.ttf', h(.02))
  
  self.findProp = false
  self.findPropX = 0
  self.findPropY = 0
  self.findPropDstX = 0
  self.findPropDstY = 0
  self.findPropStr = ''
  self.findPropPrev = 'wall'
  self.findPropPrevPrev = 'wall'
    
  self.dragging = nil
  self.dragOffsetX = 0
  self.dragOffsetY = 0
  
  self.scaling = nil
  self.scaleAnchor = nil
  self.scaleOriginX = 0
  self.scaleOriginY = 0
  self.scaleHandleX = 0
  self.scaleHandleY = 0
  
  self.grid = EditorGrid()
  self.view = EditorView()
  
  self.map = Map()
  
  self.widgets = {self.grid}
  
  table.each(self.widgets, function(widget)
    if widget.draw and widget.depth then self.view:register(widget) end
  end)
  
  --[[self.grid = {
    depth = -10000,
    draw = function()
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
  }]]

  self.props = {}
  for _, v in ipairs(data.prop) do
    table.insert(self.props, v.code)
  end
  table.sort(self.props)
  
  self.event = Event()
end

function Editor:update()
  table.each(self.widgets, f.egoexe('update'))
  
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
  self.map:update()
end

function Editor:draw()
  self.view:draw()

  if self.findProp then
    love.graphics.setFont(self.font)
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
          self.view:unregister(p)
          ovw.map.props = table.filter(ovw.map.props, function(prop) return p ~= prop end)
        end
      end)
    end,
    ['s'] = function()
      if love.keyboard.isDown('lctrl') then
        local str = 'return {'
        table.each(ovw.map.props, function(p)
          str = str .. invoke(p, 'save') .. ','
        end)
        str = str .. '}'
        love.filesystem.createDirectory('maps/' .. ovw.map.code)
        print(love.filesystem.write('maps/' .. ovw.map.code .. '/props.lua', str))
      end
    end
  }

  table.each(self.widgets, f.egoexe('keypressed', key))
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
  end
  
  self.view:mousepressed(x, y, button)
end

function Editor:mousereleased(x, y, button)
  self.dragging = nil
  self.scaling = nil
end

function Editor:snap(x, y)
  if love.keyboard.isDown('lalt') then return x, y end
  return math.round(x / self.grid.size) * self.grid.size, math.round(y / self.grid.size) * self.grid.size
end