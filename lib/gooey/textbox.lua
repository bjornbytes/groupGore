TextBox = class()

local g = love.graphics

function TextBox:init()
  self.width = 0
  self.height = 0
  self.bgColor = {0, 0, 0, 255}
  self.borderColor = {0, 0, 0, 255}

  self.font = nil
  self.fontSize = 0
  self.fontColor = {255, 255, 255, 255}

  self.hPadding = 0

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
  elseif key == 'enter' then
    self:unfocus()
  end
end

function TextBox:textinput(char)
  if self.focused then
    self.text = self.text:sub(1, self.insertAt - 1) .. char .. self.text:sub(self.insertAt)
    self.insertAt = self.insertAt + 1
    f.exe(self.onchange, self)
  end
end

function TextBox:draw(x, y)
  g.setColor(self.bgColor)
  g.rectangle('fill', x, y, self.width, self.height)
  g.setColor(self.borderColor)
  g.rectangle('line', x + .5, y + .5, self.width - 1, self.height - 1)

  g.setFont(self.font, self.fontSize)
  g.setColor(self.fontColor)

  local str = self.text
  if self.placeholder and #self.text == 0 then
    local r, g, b, a = g.getColor()
    a = a / 2
    love.graphics.setColor(r, g, b, a)
    str = self.placeholder
  end
  
  local font = g.getFont()
  x = x + self.hPadding
  y = y + self.height / 2 - font:getHeight() / 2

  g.print(str, x, y)

  if self.focused then
    local xx = x + font:getWidth(self.text:sub(1, self.insertAt - 1)) + .5
    g.setColor(self.fontColor)
    g.line(xx, y, xx, y + font:getHeight())
  end

  self.x, self.y = _x, _y
end
