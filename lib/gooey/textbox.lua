TextBox = class()

local g = love.graphics

function TextBox:init()
  self.x = 0
  self.y = 0
  self.w = 0
  self.h = 0
  self.bgColor = {0, 0, 0, 255}
  self.borderColor = {0, 0, 0, 255}

  self.font = nil
  self.fontSize = 0
  self.fontColor = {255, 255, 255, 255}

  self.hPadding = 0
  self.vPadding = 0

  self.text = ''

  self.focused = false
  self.insertAt = 1

  self.onfocus = nil
  self.onblur = nil
  self.onchange = nil

  self.onfocus = nil
end

function TextBox:focus()
  if not self.focused then
    self.focused = true
    f.exe(self.onfocus, self)
    love.keyboard.setKeyRepeat(true)
  end
end

function TextBox:blur()
  if self.focused then
    self.focused = false
    f.exe(self.onblur, self)
    love.keyboard.setKeyRepeat(false)
  end
end

function TextBox:keypressed(key)
  if key == 'backspace' and self.focused and self.insertAt > 1 then
    self.text = self.text:sub(1, self.insertAt - 2) .. self.text:sub(self.insertAt)
    self.insertAt = self.insertAt - 1
    f.exe(self.onchange, self)
  elseif key == 'left' and self.insertAt > 1 then
    self.insertAt = self.insertAt - 1
  elseif key == 'right' and self.insertAt < #self.text + 1 then
    self.insertAt = self.insertAt + 1
  end
end

function TextBox:textinput(char)
  if self.focused then
    self.text = self.text:sub(1, self.insertAt - 1) .. char .. self.text:sub(self.insertAt)
    self.insertAt = self.insertAt + 1
    f.exe(self.onchange, self)
  end
end

function TextBox:draw()

  g.setColor(self.bgColor)
  g.rectangle('fill', self.x, self.y, self.w, self.h)
  g.setColor(self.borderColor)
  g.rectangle('line', self.x + .5, self.y + .5, self.w - 1, self.h - 1)

  g.setFontPixel(self.font, self.fontSize)
  g.setColor(self.fontColor)

  local str = self.text
  if self.placeholder and #self.text == 0 then
    local r, g, b, a = g.getColor()
    a = a / 2
    love.graphics.setColor(r, g, b, a)
    str = self.placeholder
  end
  
  local font = g.getFont()
  local x = self.x + self.hPadding
  local y = self.y + self.h / 2 - font:getHeight() / 2

  g.print(str, x, y)

  if self.focused then
    local xx = self.x + self.hPadding + font:getWidth(self.text:sub(1, self.insertAt - 1)) + .5
    g.setColor(self.fontColor)
    g.line(xx, y, xx, y + font:getHeight())
  end
end
