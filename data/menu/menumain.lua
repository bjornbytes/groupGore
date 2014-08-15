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
  goregous:send({'createServer'})
  ctx.loader:activate('Creating server')
end

function MenuMain:join()
  ctx:push(ctx.serverlist)
end

function MenuMain:connect(ip)
  serverIp = ip
  serverPort = 6061
  Context:remove(self.menu)
  Context:add(Game, ctx.options.data)
  love.keyboard.setKeyRepeat(false)
end

function MenuMain:edit()
  Context:remove(self.menu)
  Context:add(Editor, ctx.options.data)
end
