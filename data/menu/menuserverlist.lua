MenuServerList = class()

local g = love.graphics
local w, h = g.width, g.height

function MenuServerList:init()
  self.servers = {}
end

function MenuServerList:load()
  ctx.ribbon.count = 0
  self:refresh()
end

function MenuServerList:draw()
  g.setColor(0, 0, 0, 100)
  g.rectangle('fill', 16, h(.3) + 16, w() - 32, h(.5) - 32)
  g.setFont('pixel', 8)

  if #self.servers == 0 then
    g.setColor(200, 50, 50)
    g.printCenter('There are no online servers', w(.5), h(.3) + 16 + (h(.5) - 32) / 2)
    return
  end

  local x, y = love.mouse.getPosition()
  for i = 1, #self.servers do
    local yy = h(.3) + 24 + (g.getFont():getHeight() * (i - 1))
    if math.inside(x, y, 16, yy, w() - 32, g.getFont():getHeight()) then
      g.setColor(0, 0, 0, 200)
      g.rectangle('fill', 16, yy, w() - 32, g.getFont():getHeight())
    end
    g.setColor(255, 255, 255)
    g.print(self.servers[i].name, 32, yy)
  end
end

function MenuServerList:keypressed(key)
  if key == 'r' then self:refresh() end
end

function MenuServerList:mousepressed(x, y, button)
  if button == 'l' then
    for i = 1, #self.servers do
      local yy = h(.3) + 24 + (g.getFont():getHeight() * (i - 1))
      if math.inside(x, y, 16, yy, w() - 32, g.getFont():getHeight()) then
        ctx.main:connect(self.servers[i].ip)
      end
    end
  end
end

function MenuServerList:refresh()
  love.thread.getChannel('goregous.in'):push({'listServers'})
  ctx.loader:activate('Finding servers')
end

function MenuServerList:setServers(servers)
  self.servers = {}
  for i = 1, #servers, 2 do
    table.insert(self.servers, {name = servers[i], ip = servers[i + 1]})
  end
end