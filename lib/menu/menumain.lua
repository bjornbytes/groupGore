MenuMain = class()

local g = love.graphics
local w, h = g.width, g.height

function MenuMain:init()
  self.menu = ovw
end

function MenuMain:load()
  ovw.ribbon.count = 5
  ovw.ribbon.margin = h(.09)
end

function MenuMain:mousepressed(x, y, button)
  if button == 'l' then
    local ribbon = ovw.ribbon:test(x, y)
    
    if ribbon == 1 then self:host()
    elseif ribbon == 2 then self:join()
    elseif ribbon == 3 then self:edit()
    elseif ribbon == 5 then love.event.quit() end
  end
end

function MenuMain:draw()
  local anchor = h(.3) + (h(.8) - h(.3)) / 2

  g.setFont('BebasNeue', 6.5)
  g.setColor(160, 160, 160)
  
  g.printCenter('Host Game', w(.05), anchor - ovw.ribbon.margin * 2, false, true)
  g.printCenter('Join Game', w(.05), anchor - ovw.ribbon.margin * 1, false, true)
  g.printCenter('Editor', w(.05), anchor + ovw.ribbon.margin * 0, false, true)
  g.printCenter('Something', w(.05), anchor + ovw.ribbon.margin * 1, false, true)
  g.printCenter('Exit', w(.05), anchor + ovw.ribbon.margin * 2, false, true)
end

function MenuMain:host()
  gorgeous:send(gorgeous.msgServerCreate, {name = username .. '\'s server'}, function(data)
    if data.success then  
      Overwatch:add(Server)
      self:connect('localhost')
    end
  end)
end

function MenuMain:join()
  gorgeous:send(gorgeous.msgMatchmake, {}, function(data)
    if #data.ip > 0 then self:connect(data.ip)
    else print('No servers running :[') end
  end)
end

function MenuMain:connect(ip)
  serverIp = ip
  serverPort = 6061
  Overwatch:remove(self.menu)
  Overwatch:add(Game)
  tick = 1
  love.keyboard.setKeyRepeat(false)
end

function MenuMain:edit()
  Overwatch:remove(self.menu)
  Overwatch:add(Editor)
end