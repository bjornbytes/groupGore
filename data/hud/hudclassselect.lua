HudClassSelect = class()

local g = love.graphics
local w, h = g.width, g.height

function HudClassSelect:init()
  self.team = purple
  self.angle = 0
  self.active = true
  
  ctx.event:on(evtClass, function(data)
    self.active = false
  end)
end

function HudClassSelect:update()
  self.angle = (self.angle + .65 * tickRate) % (2 * math.pi)
  if ctx.id and not ctx.players:get(ctx.id).active then self.active = true end
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
  
  g.setFont('BebasNeue', h(.065))
  local fh = g.getFont():getHeight()
  local x, y = love.mouse.getPosition()
  local teamStr = self.team == purple and 'purple' or 'orange'
  local hover
  local white, gray = {255, 255, 255}, {128, 128, 128}
  
  hover = math.inside(x, y, w(.08), h(.106), w(.24) + g.getFont():getWidth(teamStr), fh)
  g.setColor(hover and white or gray)
  g.print('Team', w(.08), h(.106))

  hover = false
  for i = 1, #data.class do
    g.setColor(255, 255, 255, 25)
    g.rectangle('line', w(.09) * i, h(.326), w(.08), w(.08))

    if math.inside(x, y, w(.09) * i, h(.326), w(.08), w(.08)) then
      hover = true
      self:drawClassDetails(i)
      g.setColor(255, 255, 255)
    else
      g.setColor(255, 255, 255, 150)
    end

    g.draw(data.class[i].sprite, w(.09) * i + w(.04), h(.326) + w(.04), self.angle, 1, 1, data.class[i].anchorx, data.class[i].anchory)
  end

  g.setColor(hover and white or gray)
  g.print('Class', w(.08), h(.213))

  hover = math.inside(x, y, w(.08), h(1 - .213) - fh, g.getFont():getWidth('Disconnect'), fh)
  g.setColor(hover and white or gray)
  g.print('Disconnect', w(.08), h(1 - .213) - fh)

  hover = math.inside(x, y, w(.08), h(1 - .106) - fh, g.getFont():getWidth('Exit'), fh)
  g.setColor(hover and white or gray)
  g.print('Exit', w(.08), h(1 - .106) - fh)
  
  g.setColor(self.team == purple and {190, 160, 220} or {240, 160, 140})
  g.print(self.team == purple and 'purple' or 'orange', w(.32), h(.106))
end

function HudClassSelect:keypressed(key)
  if key == 'escape' then self.active = not self.active end
  
  if self.active then
    for i = 1, #data.class do
      if key == tostring(i) then
        ctx.net:send(msgClass, {
          class = i,
          team = ctx.id > 1 and 1 or 0
        })
        return true
      end
    end
    
    return true
  end
end

function HudClassSelect:mousepressed(x, y, button)
  if self.active and button == 'l' then
    for i = 1, #data.class do
      if math.inside(x, y, w(.09) * i, h(.326), w(.08), w(.08)) then
        ctx.net:send(msgClass, {
          class = i,
          team = self.team
        })
      end
    end
    
    local str = self.team and 'purple' or 'orange'
    g.setFont('BebasNeue', h(.065))
    local font = g.getFont()
    if math.inside(x, y, w(.08), h(.106), w(.24) + font:getWidth(str), font:getHeight()) then
      self.team = 1 - self.team
    elseif math.inside(x, y, w(.08), h(1 - .213) - font:getHeight(), font:getWidth('Disconnect'), font:getHeight()) then
      ctx.net:send(msgLeave)
      ctx.net.server:disconnect()
    elseif math.inside(x, y, w(.08), h(1 - .106) - font:getHeight(), font:getWidth('Exit'), font:getHeight()) then
      ctx.net:send(msgLeave)
      ctx.net.server:disconnect()
      love.event.quit()
    end
  end
  
  return self.active
end

function HudClassSelect:mousereleased(x, y, button)
  return self.active
end

function HudClassSelect:drawClassDetails(index)
  local fh = g.getFont():getHeight()
  g.setColor(255, 255, 255)
  g.print(data.class[index].name, w(.56), h(.243) + g.getFont():getHeight())
  
  g.setFont('pixel', 8)
  g.setColor(255, 255, 255, 150)
  g.print(data.class[index].quote, w(.56) + 2, h(.243) + fh * 2)

  g.setFont('BebasNeue', h(.065))
  g.setColor(255, 255, 255)
end
