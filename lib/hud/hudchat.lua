HudChat = class()

local g = love.graphics

function HudChat:init()
  self.active = false
  self.message = ''
  self.log = ''
  self.timer = 0
  self.offset = -w(.25) - 4
  self.font = g.newFont('media/fonts/aeromatics.ttf', h() * .02)
  self.richText = nil
end

function HudChat:update()
  self.timer = timer.rot(self.timer)
  if self.active then self.timer = 2 end
  self.offset = math.lerp(self.offset, (self.timer == 0) and -w(.25) - 4 or 0, .25)
end

function HudChat:draw()
  local height = h(.25) + 2
  if self.active then height = height + (self.font:getHeight() + 6.5) end
  g.setColor(0, 0, 0, 180)
  g.rectangle('fill', 4 + self.offset, h() - (height + 4), w(.25), height)
  g.setColor(30, 30, 30, 180)
  g.rectangle('line', 4 + self.offset, h() - (height + 4), w(.25), height)
  g.setFont(self.font)
  local yy = h() - 4
  if self.active then
    g.setColor(255, 255, 255, 60)
    g.line(4.5 + self.offset, h() - 4 - self.font:getHeight() - 6.5, 3 + w(.25) + self.offset, h() - 4 - self.font:getHeight() - 6.5)
    g.setColor(255, 255, 255, 180)
    g.printf(self.message .. (self.active and '|' or ''), 4 + 4 + self.offset, math.round(yy - self.font:getHeight() - 5.5 + 2), w(.25), 'left')
    yy = yy - self.font:getHeight() - 6.5
  end

  if self.richText then
    self.richText:draw(4 + 4 + self.offset, math.round(yy - (self.font:getHeight() * select(2, self.font:getWrap(self.log, w(.25) - 2))) - 4))
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
  end
end

function HudChat:add(message)
  if #message > 0 then
    if #self.log > 0 then self.log = self.log .. '\n' end
    self.log = self.log .. message
  end

  while self.font:getHeight() * select(2, self.font:getWrap(self.log, w(.25))) > (h(.25) - 2) do
    self.log = self.log:sub(2)
  end
  
  g.setFont(self.font)
  self.richText = rich.new({self.log, w(.25) - 2, white = {255, 255, 255}, purple = {190, 160, 220}, orange = {240, 160, 140}})
  self.timer = 2
end
