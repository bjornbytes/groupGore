HudClassSelect = class()

local g = love.graphics

function HudClassSelect:init()
  self.team = purple
  self.angle = 0
  self.font = g.newFont('media/fonts/BebasNeue.ttf', h() * .065)
end

function HudClassSelect:update()
    self.angle = (self.angle + .65 * tickRate) % (2 * math.pi)
end

function HudClassSelect:draw()
  g.setColor(0, 0, 0, 153)
  g.rectangle('fill', 0, 0, w(), h())
  
  g.setColor(0, 0, 0, 89)
  g.rectangle('fill', w(.08), h(.313), w(.46), h(.35))
  g.rectangle('fill', w(.55), h(.313), w(.37), h(.58))
  
  g.setColor(255, 255, 255, 25)
  g.rectangle('line', w(.08), h(.313), w(.46), h(.35))
  g.rectangle('line', w(.55), h(.313), w(.37), h(.58))
  
  g.setFont(self.font)
  g.setColor(128, 128, 128)
  g.print('Team', w(.08), h(.106))
  g.print('Class', w(.08), h(.213))
  g.print('Disconnect', w(.08), h(1 - .213) - g.getFont():getHeight())
  g.print('Exit', w(.08), h(1 - .106) - g.getFont():getHeight())
  
  g.setColor(self.team == purple and {190, 160, 220} or {240, 160, 140})
  g.print(self.team == purple and 'purple' or 'orange', w(.32), h(.106))
  
  for i = 1, #data.class do
    g.setColor(255, 255, 255, 25)
    g.rectangle('line', w(.09) * i, h(.326), w(.08), w(.08))
    g.setColor(255, 255, 255)
    g.draw(data.class[i].sprite, w(.09) * i + w(.04), h(.326) + w(.04), self.angle, 1, 1, data.class[i].anchorx, data.class[i].anchory)
  end
end

function HudClassSelect:keypressed(key)
  if self:active() then
    for i = 1, #data.class do
      if key == tostring(i) then
        ovw.net:send(msgClass, {
          class = i,
          team = myId > 1 and 1 or 0
        })
        return true
      end
    end
  end
  
  return false
end

function HudClassSelect:mousereleased(x, y, button)
  if self:active() and button == 'l' then
    for i = 1, #data.class do
      if math.inside(x, y, w(.09) * i, h(.326), w(.08), w(.08)) then
        return ovw.net:send(msgClass, {
          class = i,
          team = self.team
        })
      end
    end
    
    local str = self.team and 'purple' or 'orange'
    if math.inside(x, y, w(.08), h(.106), w(.24) + self.font:getWidth(str), self.font:getHeight()) then
      self.team = 1 - self.team
    elseif math.inside(x, y, w(.08), h(1 - .213) - self.font:getHeight(), self.font:getWidth('Disconnect'), self.font:getHeight()) then
      ovw.net:send(msgLeave)
      Overwatch:remove(ovw)
      Overwatch:add(Menu)
    elseif math.inside(x, y, w(.08), h(1 - .106) - self.font:getHeight(), self.font:getWidth('Exit'), self.font:getHeight()) then
      ovw.net:send(msgLeave)
      love.event.quit()
    end
  end
end

function HudClassSelect:active()
  return myId and not ovw.players:get(myId).active
end