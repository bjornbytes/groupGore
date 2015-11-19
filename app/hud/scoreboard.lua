local Scoreboard = class()

local g = love.graphics

function Scoreboard:init()
  ctx.event:on(app.core.net.events.class, function(data) self:refresh() end)
  ctx.event:on(app.core.net.events.dead, function(data) self:refresh() end)
  ctx.event:on(app.core.net.events.leave, function(data) self:refresh() end)

  self.names = {[0] = '', [1] = ''}
  self.ks = {[0] = '', [1] = ''}
  self.ds = {[0] = '', [1] = ''}
  self.nameWidth = {[0] = 0, [1] = 0}
  self.ksWidth = {[0] = 0, [1] = 0}
  self.dsWidth = {[0] = 0, [1] = 0}
  self.width = {[0] = 0, [1] = 0}
  self.height = {[0] = 0, [1] = 0}

  self:refresh()

  self.offset = {[0] = -love.graphics.getWidth(), [1] = love.graphics.getWidth() * 2}
end

function Scoreboard:update()
  if love.keyboard.isDown('tab') then
    self.offset[0] = math.lerp(self.offset[0], 0, math.min(30 * tickRate, 1))
    self.offset[1] = math.lerp(self.offset[1], ctx.hud.u - self.width[1], math.min(30 * tickRate, 1))
    if math.abs(self.offset[1] - (ctx.hud.u - self.width[1])) < 2 then
      self.offset[1] = ctx.hud.u - self.width[1]
    end
  else
    self.offset[0] = math.lerp(self.offset[0], -self.width[0] - 1, math.min(30 * tickRate, 1))
    self.offset[1] = math.lerp(self.offset[1], ctx.hud.u, math.min(30 * tickRate, 1))
    if math.abs(self.offset[1] - ctx.hud.u) < 2 then
      self.offset[1] = ctx.hud.u
    end
  end
end

function Scoreboard:draw()
  local u, v = ctx.hud.u, ctx.hud.v
  g.setFont('pixel', 8)
  local font = g.getFont()

  for i = 0, 1 do
    if (i == 0 and self.offset[0] > -self.width[0]) or (i == 1 and self.offset[1] < u) then
      local xx = self.offset[i]
      local yy = v * .5 - (self.height[i] / 2) + 1
      g.setColor(0, 0, 0, 180)
      g.rectangle('fill', xx, yy, self.width[i], self.height[i] - (#self.teams[i] == 0 and 1 or 0), false, true)
      g.setColor(30, 30, 30, 180)
      g.rectangle('line', xx, yy, self.width[i], self.height[i] - (#self.teams[i] == 0 and 1 or 0), false, true)
      g.setColor(255, 255, 255)
      g.print('username', xx + 10, yy + 4)
      g.print('k', xx + 10 + self.nameWidth[i] + 16, yy + 4)
      g.print('d', xx + 10 + self.nameWidth[i] + 16 + self.ksWidth[i] + 16, yy + 4)
      g.setColor(i == 0 and {190, 160, 220} or {240, 160, 140})
      g.print(self.names[i], xx + 10, yy + 4 + font:getHeight() + 2)
      g.print(self.ks[i], xx + 10 + self.nameWidth[i] + 16, yy + 4 + font:getHeight() + 2)
      g.print(self.ds[i], xx + 10 + self.nameWidth[i] + 16 + self.ksWidth[i] + 16, yy + 4 + font:getHeight() + 2)
    end
  end
end

function Scoreboard:refresh()
  self.teams = {[0] = {}, [1] = {}}
  ctx.players:each(function(p)
    table.insert(self.teams[p.team], {name = p.username, kills = p.kills, deaths = p.deaths})
  end)

  local comp = function(a, b) return (a.kills == b.kills) and (a.deaths < b.deaths) or (a.kills > b.kills) end
  table.sort(self.teams[0], comp)
  table.sort(self.teams[1], comp)

  g.setFont('pixel', 8)
  local font = g:getFont()

  for i = 0, 1 do
    self.names[i], self.ks[i], self.ds[i] = '', '', ''
    for j = 1, #self.teams[i] do
      self.names[i] = self.names[i] .. self.teams[i][j].name .. '\n'
      self.ks[i] = self.ks[i] .. self.teams[i][j].kills .. '\n'
      self.ds[i] = self.ds[i] .. self.teams[i][j].deaths .. '\n'
    end

    self.names[i] = self.names[i]:sub(1, #self.names[i] - 1)
    self.ks[i] = self.ks[i]:sub(1, #self.ks[i] - 1)
    self.ds[i] = self.ds[i]:sub(1, #self.ds[i] - 1)

    self.nameWidth[i] = font:getWrap(self.names[i], math.huge)
    self.nameWidth[i] = math.max(self.nameWidth[i], font:getWidth('username'))
    self.ksWidth[i] = font:getWrap(self.ks[i], math.huge)
    self.ksWidth[i] = math.max(self.ksWidth[i], font:getWidth('k'))
    self.dsWidth[i] = font:getWrap(self.ds[i], math.huge)
    self.dsWidth[i] = math.max(self.dsWidth[i], font:getWidth('d'))
    self.width[i] = self.nameWidth[i] + 16 + self.ksWidth[i] + 16 + self.dsWidth[i] + 18
    self.height[i] = (#self.teams[i] + 1) * font:getHeight() + 12
  end
end

return Scoreboard
