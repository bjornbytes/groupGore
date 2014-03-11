Gooey = class()

local g = love.graphics
local function w(x) x = x or 1 return love.window.getWidth() * x end
local function h(x) x = x or 1 return love.window.getHeight() * x end
local function arg(x) return x / 100 end

getmetatable(Gooey).__index = love.graphics

function Gooey:init()
  self.align = {h = 'left', v = 'top'}
  self.fonts = {}
  self.images = {}
  self.inputs = {}
  self.focused = nil
end

function Gooey:textinput(character)
  if self.focused then
    if character:match('%w') then self.inputs[self.focused].val = self.inputs[self.focused].val .. character end
  end
end

function Gooey:keypressed(key)
  if key == 'backspace' and self.focused then
    self.inputs[self.focused].val = self.inputs[self.focused].val:sub(1, -2)
  end
end

function Gooey:update()
  table.each(self.interps, function(v) v.current = math.lerp(v.current, v.target, .25) end)
end

function Gooey:resize()
  table.clear(self.fonts)
end

function Gooey.background(obj, mode)
  if not obj then return end

  if not obj.type then
    g.setColor(obj)
    g.rectangle('fill', 0, 0, w(), h())
  elseif obj.type() == 'Image' then
    mode = mode or 'stretch'
    if mode == 'stretch' then
      g.setColor(255, 255, 255)
      g.draw(obj, 0, 0, 0, w() / obj:getWidth(), h() / obj:getHeight())
    end
  end
end

function Gooey:push(x, y)
  love.graphics.push()
  love.graphics.translate(-x, -y)
end

function Gooey:pop()
  love.graphics.pop()
end

function Gooey:align(h, v)
  self.align.h = h
  self.align.v = v or self.align.v
end

function Gooey:layout(x, y, w, h)
  --
end

function Gooey:font(name, size)
  size = arg(size)
  self.fonts[name] = self.fonts[name] or {}
  if not self.fonts[name][size] then
    self.fonts[name][size] = love.graphics.newFont('media/fonts/' .. name .. '.ttf', h() * size)
  end

  self.setFont(self.fonts[name][size])
end

function Gooey:image(name)
  self.images[name] = self.images[name] or love.graphics.newImage('media/graphics/' .. name .. '.png')
  return self.images[name]
end

function Gooey:addInput(name, default)
  self.inputs[name] = {
    val = default,
    default = default
  }
end

function Gooey:focus(input)
  self:unfocus()
  self.focused = input
  if self.inputs[self.focused].default == self.inputs[self.focused].val then self.inputs[self.focused].val = '' end
end

function Gooey:unfocus()
  if not self.focused then return end
  if self.inputs[self.focused].val == '' and self.inputs[self.focused].default then self.inputs[self.focused].val = self.inputs[self.focused].default end
  self.focused = nil
end

function Gooey:drawInput(name, x, y)
  local fh = self.getFont():getHeight()
  local iw, ih = w(.2), fh * 1.6
  
  self.setColor(51, 49, 54, 160)
  self.rectangleCenter('fill', x, y, iw, ih)
  self.setColor(51, 49, 54, 255)
  self.rectangleCenter('line', x, y, iw, ih)
  
  self.setColor(140, 107, 84)
  local str = self.inputs[name].val
  if name == 'password' then str = string.rep('•', #str) end
  self.print(str, x - (iw / 2) + (fh / 2), y - (fh / 2))
  if self.focused == name then
    self.line(x - (iw / 2) + (fh / 2) + self.getFont():getWidth(str) + 1, y - (fh / 2), x - (iw / 2) + (fh / 2) + self.getFont():getWidth(str) + 1, y - (fh / 2) + fh)
  end
end

function Gooey.rectangleCenter(style, x, y, w, h, pix)
  local ox, oy = math.round(x - (w / 2)), math.round(y - (h / 2))
  if pix then ox = ox + .5 oy = oy + .5 end
  g.rectangle(style, ox, oy, w, h)
end

function Gooey.printCenter(str, x, y, h, v)
  local xx = x - ((h or (h == nil)) and (g.getFont():getWidth(str) / 2) or 0)
  local yy = y - ((v or (v == nil)) and (g.getFont():getHeight() / 2) or 0)
  g.print(str, xx, yy)
end