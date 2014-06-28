HudClassSelect = class()

local g = love.graphics

function HudClassSelect:init()
  self.team = purple
  self.angle = 0
  self.active = true
  self.offense = 0
  self.defense = 0
  self.utility = 0
  
  ctx.event:on(evtClass, function(data)
    self.active = false
  end)
end

function HudClassSelect:update()
  self.angle = (self.angle + .65 * tickRate) % (2 * math.pi)
  if not love.mouse.isVisible() then love.mouse.setVisible(true) end

  local u, v = ctx.hud.u, ctx.hud.v
  local x, y = ctx.view:frameMouseX(), ctx.view:frameMouseY()
  for i = 1, #data.class do
    if math.inside(x, y, u * .09 * i, v * .326, u * .08, u * .08) then
      self.offense = math.lerp(self.offense, data.class[i].offense, math.min(12 * tickRate, 1))
      self.defense = math.lerp(self.defense, data.class[i].defense, math.min(12 * tickRate, 1))
      self.utility = math.lerp(self.utility, data.class[i].utility, math.min(12 * tickRate, 1))
      print(i)
    end
  end
end

function HudClassSelect:draw()
  local u, v = ctx.hud.u, ctx.hud.v

  g.setColor(0, 0, 0, 153)
  g.rectangle('fill', 0, 0, u, v)

  g.setColor(0, 0, 0, 89)
  g.rectangle('fill', u * .08, v * .313, u * .46, v * .35)
  g.rectangle('fill', u * .55, v * .313, u * .37, v * .58)
  
  g.setColor(255, 255, 255, 25)
  g.rectangle('line', u * .08, v * .313, u * .46, v * .35)
  g.rectangle('line', u * .55, v * .313, u * .37, v * .58)
  
  g.setFont('BebasNeue', v * .065)
  local fh = g.getFont():getHeight()
  local x, y = ctx.view:frameMouseX(), ctx.view:frameMouseY()
  local teamStr = self.team == purple and 'purple' or 'orange'
  local hover
  local white, gray = {255, 255, 255}, {128, 128, 128}
  
  hover = math.inside(x, y, u * .08, v * .106, u * .24 + g.getFont():getWidth(teamStr), fh)
  g.setColor(hover and white or gray)
  g.print('Team', u * .08, v * .106)

  hover = false
  for i = 1, #data.class do
    g.setColor(255, 255, 255, 25)
    g.rectangle('line', u * .09 * i, v * .326, u * .08, u * .08)

    if math.inside(x, y, u * .09 * i, v * .326, u * .08, u * .08) then
      hover = true
      self:drawClassDetails(i)
      g.setColor(255, 255, 255)
    else
      g.setColor(255, 255, 255, 150)
    end

    g.setFont('pixel', 8)
    g.printCenter(data.class[i].name, u * .09 * i + u * .04, v * .326 + u * .04)
    g.setFont('BebasNeue', v * .065)
  end

  g.setColor(hover and white or gray)
  g.print('Class', u * .08, v * .213)

  hover = math.inside(x, y, u * .08, v * (1 - .213) - fh, g.getFont():getWidth('Disconnect'), fh)
  g.setColor(hover and white or gray)
  g.print('Disconnect', u * .08, v * (1 - .213) - fh)

  hover = math.inside(x, y, u * .08, v * (1 - .106) - fh, g.getFont():getWidth('Exit'), fh)
  g.setColor(hover and white or gray)
  g.print('Exit', u * .08, v * (1 - .106) - fh)
  
  g.setColor(self.team == purple and {190, 160, 220} or {240, 160, 140})
  g.print(self.team == purple and 'purple' or 'orange', u * .32, v * .106)
end

function HudClassSelect:keypressed(key)
  if key == 'escape' and ctx.players:get(ctx.id).class then self.active = not self.active end
  
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

function HudClassSelect:mousepressed() return self.active end

function HudClassSelect:mousereleased(x, y, button)
  local u, v = ctx.hud.u, ctx.hud.v
  x, y = ctx.view:frameMouseX(), ctx.view:frameMouseY()

  if self.active and button == 'l' then
    for i = 1, #data.class do
      if math.inside(x, y, u * .09 * i, v * .326, u * .08, u * .08) then
        ctx.net:send(msgClass, {
          class = i,
          team = self.team
        })
      end
    end
    
    local str = self.team and 'purple' or 'orange'
    g.setFont('BebasNeue', v * .065)
    local font = g.getFont()
    if math.inside(x, y, u * .08, v * .106, u * .24 + font:getWidth(str), font:getHeight()) then
      self.team = 1 - self.team
    elseif math.inside(x, y, u * .08, v * (1 - .213) - font:getHeight(), font:getWidth('Disconnect'), font:getHeight()) then
      ctx.net:send(msgLeave)
      ctx.net.server:disconnect()
    elseif math.inside(x, y, u * .08, v * (1 - .106) - font:getHeight(), font:getWidth('Exit'), font:getHeight()) then
      ctx.net:send(msgLeave)
      ctx.net.server:disconnect()
      love.event.quit()
    end
  end
  
  return self.active
end

function HudClassSelect:drawClassDetails(index)
  local u, v = ctx.hud.u, ctx.hud.v
  local fh = g.getFont():getHeight()
  g.setColor(255, 255, 255)
  g.print(data.class[index].name, u * .56, v * .243 + g.getFont():getHeight())
  
  g.setFont('pixel', 8)
  g.setColor(255, 255, 255, 150)
  g.print(data.class[index].quote, u * .56 + 2, v * .243 + fh * 2)

  g.setFont('BebasNeue', v * .04)
  g.print('offense\ndefense\nutility', u * .56 + 2, v * .243 + fh * 2.75)

  g.setColor(84, 28, 28)
  g.rectangle('fill', u * .65 + .5, v * .243 + fh * 2.75 + 4.5, u * .2 * (self.offense / 10), g.getFont():getHeight() - 8)
  g.setColor(70, 96, 67)
  g.rectangle('fill', u * .65 + .5, v * .243 + fh * 2.75 + 4.5 + g.getFont():getHeight(), u * .2 * (self.defense / 10), g.getFont():getHeight() - 8)
  g.setColor(30, 94, 99)
  g.rectangle('fill', u * .65 + .5, v * .243 + fh * 2.75 + 4.5 + 2 * g.getFont():getHeight(), u * .2 * (self.utility / 10), g.getFont():getHeight() - 8)

  g.setColor(255, 255, 255, 150)
  g.rectangle('line', u * .65 + .5, v * .243 + fh * 2.75 + 4.5, u * .2, g.getFont():getHeight() - 8)
  g.rectangle('line', u * .65 + .5, v * .243 + fh * 2.75 + 4.5 + g.getFont():getHeight(), u * .2, g.getFont():getHeight() - 8)
  g.rectangle('line', u * .65 + .5, v * .243 + fh * 2.75 + 4.5 + 2 * g.getFont():getHeight(), u * .2, g.getFont():getHeight() - 8)

  g.setFont('BebasNeue', v * .065)
  g.setColor(255, 255, 255)
end
