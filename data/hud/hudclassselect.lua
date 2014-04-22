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
  return self.active
end

function HudClassSelect:mousereleased(x, y, button)
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
      Context:remove(ctx)
      Context:add(Menu)
    elseif math.inside(x, y, w(.08), h(1 - .106) - font:getHeight(), font:getWidth('Exit'), font:getHeight()) then
      ctx.net:send(msgLeave)
      love.event.quit()
    end
  end
  
  if self.active then return true end
end
