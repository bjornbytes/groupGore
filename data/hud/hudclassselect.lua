HudClassSelect = class()

local g = love.graphics

function HudClassSelect:init()
  self.team = love.math.random(purple, orange)
  self.angle = 0
  self.active = true
  self.offense = 0
  self.defense = 0
  self.utility = 0
  self.teamCt = {0, 0}

  ctx.event:on(evtClass, function(data)
    if data.id == ctx.id then self.active = false end
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
    end
  end

  self.teamCt[0] = 0
  self.teamCt[1] = 0
  ctx.players:each(function(p)
    self.teamCt[p.team] = self.teamCt[p.team] + 1
  end)
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
      g.setColor(255, 255, 255, data.class[i].locked and 50 or 255)
    else
      g.setColor(255, 255, 255, data.class[i].locked and 50 or 150)
    end

    local s = u * .08 / data.class[i].portrait:getWidth()
    g.draw(data.class[i].portrait, u * .09 * i, v * .326, 0, s, s)
    g.setFont('pixel', 8)
    g.print(data.class[i].name, u * .09 * i + 4, v * .326)
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

  g.setColor(190, 160, 220)
  g.print(self.teamCt[0], u * .5, v * .106)
  g.setColor(240, 160, 140)
  g.print(self.teamCt[1], u * .5 + math.max(u * .05, g.getFont():getWidth(tostring(self.teamCt[0]))), v * .106)
end

function HudClassSelect:keypressed(key)
  if key == 'escape' and ctx.players:get(ctx.id).class then self.active = not self.active end

  if self.active then
    for i = 1, #data.class do
      if not data.class[i].locked and key == tostring(i) then
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
      if not data.class[i].locked and math.inside(x, y, u * .09 * i, v * .326, u * .08, u * .08) then
        ctx.net:send(msgClass, {
          class = i,
          team = self.team
        })
        ctx.event:emit('sound.play', {sound = 'click', gui = true})
      end
    end

    local str = self.team and 'purple' or 'orange'
    g.setFont('BebasNeue', v * .065)
    local font = g.getFont()
    if math.inside(x, y, u * .08, v * .106, u * .24 + font:getWidth(str), font:getHeight()) then
      ctx.event:emit('sound.play', {sound = 'click', gui = true})
      self.team = 1 - self.team
    elseif math.inside(x, y, u * .08, v * (1 - .213) - font:getHeight(), font:getWidth('Disconnect'), font:getHeight()) then
      ctx.event:emit('sound.play', {sound = 'click', gui = true})
      ctx.event:emit('game.quit')
    elseif math.inside(x, y, u * .08, v * (1 - .106) - font:getHeight(), font:getWidth('Exit'), font:getHeight()) then
      ctx.event:emit('sound.play', {sound = 'click', gui = true})
      love.event.quit()
    end
  end

  return self.active
end

function HudClassSelect:drawClassDetails(index)
  local class = data.class[index]
  local u, v = ctx.hud.u, ctx.hud.v
  local fh = g.getFont():getHeight()
  local yy = v * .318
  g.setColor(255, 255, 255)
  g.print(class.name, u * .56, yy)

  yy = yy + v * .08
  g.setFont('BebasNeue', v * .03)
  g.setColor(self.team == purple and {190, 160, 220} or {240, 160, 140})
  g.print(class.quote, u * .56 + 2, yy)

  yy = yy + v * .045
  g.setFont('BebasNeue', v * .04)
  g.setColor(255, 255, 255, 150)
  g.print('offense\ndefense\nutility', u * .56 + 2, yy)

  g.setColor(84, 28, 28)
  g.rectangle('fill', u * .65 + .5, yy + v * .012, u * .2 * (self.offense / 10), v * .025)
  g.setColor(70, 96, 67)
  g.rectangle('fill', u * .65 + .5, yy + v * .012 + g.getFont():getHeight(), u * .2 * (self.defense / 10), v * .025)
  g.setColor(30, 94, 99)
  g.rectangle('fill', u * .65 + .5, yy + v * .012 + 2 * g.getFont():getHeight(), u * .2 * (self.utility / 10), v * .025)

  g.setColor(255, 255, 255, 150)
  g.rectangle('line', u * .65 + .5, yy + v * .012, u * .2, v * .025)
  g.rectangle('line', u * .65 + .5, yy + v * .012 + g.getFont():getHeight(), u * .2, v * .025)
  g.rectangle('line', u * .65 + .5, yy + v * .012 + 2 * g.getFont():getHeight(), u * .2, v * .025)

  yy = yy + v * .012 + 2 * g.getFont():getHeight() + v * .05
  for i = 1, 5 do
    local icon = data.media.graphics.icons[class.slots[i].code]
    local s = u * .03 / icon:getWidth()
    g.setColor(255, 255, 255)
    g.draw(icon, u * .56 + 2, yy, 0, s, s)
    g.setColor(255, 255, 255, 200)
    g.print(class.slots[i].name, u * .56 + u * .01 + s * icon:getWidth(), yy - v * .002)
    yy = yy + s * icon:getWidth() + v * .009
  end

  g.setFont('BebasNeue', v * .065)
  g.setColor(255, 255, 255)
end
