local rich = require 'lib/richtext'

HudChat = class()

local g = love.graphics
local w, h = g.width, g.height

function HudChat:init()
  self.active = false
  self.message = ''
  self.log = ''
  self.timer = 0
  self.offset = -love.graphics.getWidth()
  self.richText = nil
end

function HudChat:update()
  local u, v = ctx.hud.u, ctx.hud.v
  self.timer = timer.rot(self.timer)
  if self.active then self.timer = 2 end
  self.offset = math.lerp(self.offset, (self.timer == 0) and -(u * .35) - 4 or 0, math.min(tickRate * 30, 1))
end

function HudChat:draw()
  local u, v = ctx.hud.u, ctx.hud.v
  local width = u * .35
  if not self.richText then return end

  g.setFont('pixel', 8)
  local font = g.getFont()
  local height = self.richText.height - 2
  if self.active then height = height + (font:getHeight() + 6.5) - 1 end

  g.setColor(0, 0, 0, 180)
  g.rectangle('fill', 4 + self.offset, v - (height + 4), width, height)
  g.setColor(30, 30, 30, 180)
  g.rectangle('line', 4 + self.offset, v - (height + 4), width, height)
  local yy = v - 4
  if self.active then
    g.setColor(255, 255, 255, 60)
    g.line(4.5 + self.offset, v - 4 - font:getHeight() - 6.5, 3 + width + self.offset, v - 4 - font:getHeight() - 6.5)
    g.setColor(255, 255, 255, 180)
    g.printf(self.message .. (self.active and '|' or ''), 4 + 4 + self.offset, math.round(yy - font:getHeight() - 5.5 + 2), width, 'left')
    yy = yy - font:getHeight() - 6.5
  end

  if self.richText then
    self.richText:draw(4 + 4 + self.offset, math.round(yy - self.richText.height + 4))
  end
end

function HudChat:textinput(character)
  if self.active then
    self.message = self.message .. character
    ctx.event:emit('sound.play', {sound = 'click', gui = true})
  end
end

function HudChat:keypressed(key)
  if self.active then
    if key == 'backspace' then self.message = self.message:sub(1, -2)
    elseif key == 'return' or key == 'escape' then
      if #self.message > 0 and key ~= 'escape' then
        ctx.net:send(msgChat, {
          message = self.message
        })
      end
      self.active = false
      self.message = ''
      ctx.event:emit('sound.play', {sound = 'click', gui = true})
    end

    return true
  elseif key == 'return' then
    self.active = true
    self.message = ''
    ctx.event:emit('sound.play', {sound = 'click', gui = true})
  end
end

function HudChat:add(data)
  local message = data.message
  local u, v = ctx.hud.u, ctx.hud.v
  local width = u * .35

  if #message > 0 then
    if #self.log > 0 then self.log = self.log .. '\n' end
    self.log = self.log .. message
  end

  g.setFont('pixel', 8)
  while g.getFont():getHeight() * select(2, g.getFont():getWrap(self.log, width)) > (v * .25 - 2) do
    self.log = self.log:sub(2)
  end

  self.log = '{white}' .. self.log

  self:refresh()
  self.timer = math.min(2 + (#message / 50), 5)
end

function HudChat:resize()
  self:refresh()
end

function HudChat:refresh(width)
  local u, v = ctx.hud.u, ctx.hud.v
  local width = u * .35
  self.richText = rich:new({self.log, width, white = {255, 255, 255}, purple = {190, 160, 220}, orange = {240, 160, 140}, red = {255, 0, 0}, green = {0, 255, 0}})
end
