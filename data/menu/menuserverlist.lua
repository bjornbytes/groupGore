MenuServerList = class()

local g = love.graphics

function MenuServerList:activate()
  ctx.ribbon.count = 0
  self:refresh()
end

function MenuServerList:draw()
  local u, v = ctx.u, ctx.v
  local mx, my = love.mouse.getPosition()
  local hover = math.inside(mx, my, 0, .2 * v, u, .1 * v)
  g.setColor(0, 0, 0, hover and 50 or 0)
  g.rectangle('fill', 0, .2 * v, u, .1 * v)
  g.setColor(hover and {255, 255, 255, 200} or {200, 200, 200, 200})
  g.setFont('BebasNeue', .065 * v)
  g.printCenter('refresh', .05 * u, .25 * v, false, true)

  g.setColor(0, 0, 0, 100)
  g.rectangle('fill', 16, .3 * v + 16, u - 32, .5 * v - 32)
  g.setFont('pixel', 8)

  if #self.servers == 0 then
    g.setColor(200, 50, 50)
    g.printCenter('There are no online servers', .5 * u, .3 * v + 16 + (.5 * v - 32) / 2)
    return
  end

  local x, y = love.mouse.getPosition()
  for i = 1, #self.servers do
    local yy = .3 * v + 24 + (g.getFont():getHeight() * (i - 1))
    if math.inside(mx, my, 16, yy, u - 32, g.getFont():getHeight()) then
      g.setColor(0, 0, 0, 200)
      g.rectangle('fill', 16, yy, u - 32, g.getFont():getHeight())
    end
    g.setColor(255, 255, 255)
    g.print(self.servers[i].name, 32, yy)
  end

end

function MenuServerList:keypressed(key)
  if key == 'r' then self:refresh() end
end

function MenuServerList:mousepressed(x, y, button)
  local u, v = ctx.u, ctx.v
  if button == 'l' then
    for i = 1, #self.servers do
      local yy = .3 * v + 24 + (g.getFont():getHeight() * (i - 1))
      if math.inside(x, y, 16, yy, u - 32, g.getFont():getHeight()) then
        ctx:connect(self.servers[i].ip)
      end
    end

    if math.inside(x, y, 0, .2 * v, u, .1 * v) then
      self:refresh()
    end
  end
end

function MenuServerList:refresh()
  self.servers = app.goregous:listServers()
end

