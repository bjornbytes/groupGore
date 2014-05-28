MenuMain = class()

local g = love.graphics
local w, h = g.width, g.height

function MenuMain:init()
  self.menu = ctx
end

function MenuMain:load()
  ctx.ribbon.count = 4
  ctx.ribbon.margin = h(.1)
end

function MenuMain:draw()
  local anchor = h(.3) + (h(.8) - h(.3)) / 2

  g.setFont('BebasNeue', h(.065))
  g.setColor(160, 160, 160)
  
  g.printCenter('Host Game', w(.05), anchor - ctx.ribbon.margin * 1.5, false, true)
  g.printCenter('Join Game', w(.05), anchor - ctx.ribbon.margin * .5, false, true)
  g.printCenter('Editor', w(.05), anchor + ctx.ribbon.margin * .5, false, true)
  g.printCenter('Exit', w(.05), anchor + ctx.ribbon.margin * 1.5, false, true)
end

function MenuMain:keypressed(key)
  if key == 'return' then self:host() end
end

function MenuMain:mousepressed(x, y, button)
  if button == 'l' then
    local ribbon = ctx.ribbon:test(x, y)
    
    if ribbon == 1 then self:host()
    elseif ribbon == 2 then self:join()
    elseif ribbon == 3 then self:edit()
    elseif ribbon == 4 then love.event.quit() end
  end
end

function MenuMain:host()
  Context:add(Server)
  self:connect('localhost')
  do return end
  gorgeous:send(gorgeous.msgServerCreate, {name = username .. '\'s server'}, function(data)
    if data.success then  
      Context:add(Server)
      self:connect('localhost')
    end
  end)
end

function MenuMain:join()
  if love.system.getClipboardText():match('%d+%.%d+%.%d+%.%d+') then
    return self:connect(love.system.getClipboardText())
  end

  self:connect('')
end

function MenuMain:connect(ip)
  serverIp = ip
  serverPort = 6061
  Context:remove(self.menu)
  Context:add(Game)
  tick = 1
  love.keyboard.setKeyRepeat(false)
end

function MenuMain:edit()
  Context:remove(self.menu)
  Context:add(Editor)
end
