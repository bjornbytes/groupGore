EditorMenu = class()

local g = love.graphics
local w, h = g.width, g.height

function EditorMenu:init()
  self.w = w(.2)
  self.h = h()
  self.x = -self.w
  self.y = 0
  
  self.active = false
  
  self.props = {}
  for _, v in ipairs(data.prop) do
    table.insert(self.props, v.code)
  end
  
  table.sort(self.props)
  
  self.lastProp = 'wall'
end

function EditorMenu:update()
  if self.active then
    self.x = math.lerp(self.x, 0, tickRate * 20)
  else
    self.x = math.lerp(self.x, -self.w, tickRate * 20)
  end
end

function EditorMenu:draw()
  local x, y = self.x, self.y
  local padding = g.minUnit(.01)
  if math.round(x) > -self.w then
    g.setColor(10, 10, 10, 200)
    g.rectangle('fill', x, y, self.w, self.h)
    
    g.setColor(200, 200, 200)
    g.setFont('aeromatics', 2.8)
    g.print(ovw.map.name, x + padding, y + padding)
    
    g.setFont('aeromatics', 2.6)
    g.print('Props', x + padding, y + h(.08))
    
    g.setColor(255, 255, 255)
    g.setFont('aeromatics', 2.4)
    for i = 1, #self.props do
      g.print(self.props[i], x + padding, y + h(.09) + (g.getFont():getHeight() + 1) * i)
    end
  end
end

function EditorMenu:keypressed(key)
  if key == ' ' then
    self.active = not self.active
  end
end

function EditorMenu:mousepressed(x, y, button)
  local padding = g.minUnit(.01)
  g.setFont('aeromatics', 2.4)
  if button == 'l' then
    for i = 1, #self.props do
      if math.inside(x, y, self.x, self.y + h(.09) + (g.getFont():getHeight() + 1) * i, self.w, g.getFont():getHeight()) then
        table.insert(ovw.map.props, ovw.map:initProp({
          kind = self.props[i],
          x = ovw.view.x + ovw.view.w / 2,
          y = ovw.view.y + ovw.view.h / 2,
          w = 64,
          h = 64,
          z = 64
        }))
        self.lastProp = self.props[i]
      end
    end
  end
end