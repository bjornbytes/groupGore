MenuMain = class()

function MenuMain:init()
  self.font = love.graphics.newFont('media/fonts/BebasNeue.ttf', h(.065))
  self.menu = ovw
end

function MenuMain:load()
  ovw.ribbon.count = 3
  ovw.ribbon.margin = h(.1)
end

function MenuMain:mousepressed(x, y, button)
  if button == 'l' then
    local ribbon = ovw.ribbon:test(x, y)
    
    if ribbon == 1 then self:host()
    elseif ribbon == 2 then self:join()
    elseif ribbon == 3 then love.event.quit() end
  end
end

function MenuMain:draw()
  local g = love.graphics
  
  local anchor = h(.3) + (h(.8) - h(.3)) / 2

  g.setFont(self.font)
  g.setColor(160, 160, 160)
  
  g.printCenter('Host Game', w(.05), anchor - ovw.ribbon.margin, false, true)
  g.printCenter('Join Game', w(.05), anchor, false, true)
  g.printCenter('Exit', w(.05), anchor + ovw.ribbon.margin, false, true)
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