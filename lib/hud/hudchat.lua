HudChat = class()

local g = love.graphics
local w, h = g.width, g.height

function HudChat:init()
  self.active = false
  self.message = ''
  self.log = ''
  self.timer = 0
  self.width = w(.35)
  self.offset = -self.width - 4
  self.font = g.newFont('media/fonts/aeromatics.ttf', h() * .02)
  self.richText = nil
end

function HudChat:update()
  self.timer = timer.rot(self.timer)
  if self.active then self.timer = 2 end
  self.offset = math.lerp(self.offset, (self.timer == 0) and -self.width - 4 or 0, .25)
end

function HudChat:draw()
  if not self.richText then return end
  
  g.setFontPixel('pixel', 8)
  local font = g.getFont()
  local height = self.richText.height - 2
  if self.active then height = height + (font:getHeight() + 6.5) - 1 end
  
  g.setColor(0, 0, 0, 180)
  g.rectangle('fill', 4 + self.offset, h() - (height + 4), self.width, height)
  g.setColor(30, 30, 30, 180)
  g.rectangle('line', 4 + self.offset, h() - (height + 4), self.width, height)
  local yy = h() - 4
  if self.active then
    g.setColor(255, 255, 255, 60)
    g.line(4.5 + self.offset, h() - 4 - font:getHeight() - 6.5, 3 + self.width + self.offset, h() - 4 - font:getHeight() - 6.5)
    g.setColor(255, 255, 255, 180)
    g.printf(self.message .. (self.active and '|' or ''), 4 + 4 + self.offset, math.round(yy - font:getHeight() - 5.5 + 2), self.width, 'left')
    yy = yy - font:getHeight() - 6.5
  end

  if self.richText then
    self.richText:draw(4 + 4 + self.offset, math.round(yy - self.richText.height + 4))
  end
end

function HudChat:textinput(character)
  if self.active then self.message = self.message .. character end
end

function HudChat:keypressed(key)
  if self.active then
    if key == 'backspace' then self.message = self.message:sub(1, -2)
    elseif key == 'return' then
      if #self.message > 0 then
        ovw.net:send(msgChat, {
          message = self.message
        })
      end
      self.active = false
      self.message = ''
      love.keyboard.setKeyRepeat(false)
    end
    
    return true
  elseif key == 'return' then
    self.active = true
    self.message = ''
    love.keyboard.setKeyRepeat(true)
  end
end

function HudChat:add(data)
  local message = data.message
  
  if #message > 0 then
    if #self.log > 0 then self.log = self.log .. '\n' end
    self.log = self.log .. message
  end

  g.setFontPixel('pixel', 8)
  while g.getFont():getHeight() * select(2, g.getFont():getWrap(self.log, self.width)) > (h(.25) - 2) do
    self.log = self.log:sub(2)
  end
  
  self.richText = rich.new({self.log, self.width, white = {255, 255, 255}, purple = {190, 160, 220}, orange = {240, 160, 140}})
  self.timer = 2
end