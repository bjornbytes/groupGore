MenuMain = class()

function MenuMain:init()
  self.font = love.graphics.newFont('media/fonts/BebasNeue.ttf', h(.065))
end

function MenuMain:load()
  ovw.ribbon.count = 5
  ovw.ribbon.margin = h(.09)
end

function MenuMain:mousepressed(x, y, button)
  local ribbon = ovw.ribbon:test(x, y)
  
  if ribbon == 1 then self:host()
  elseif ribbon == 2 then self:play()
  elseif ribbon == 5 then love.event.quit() end
end

function MenuMain:draw()
  local g = love.graphics
  
  local anchor = h(.3) + (h(.8) - h(.3)) / 2

  g.setFont(self.font)
  g.setColor(160, 160, 160)
  
  local margin = h(.09)
  g.printCenter('Host Game', w(.05), anchor - 2 * margin, false, true)
  g.printCenter('Join Game', w(.05), anchor - margin, false, true)
  g.printCenter('Stats', w(.05), anchor, false, true)
  g.printCenter('Options', w(.05), anchor + margin, false, true)
  g.printCenter('Exit', w(.05), anchor + 2 * margin, false, true)
end

function MenuMain:host()
  gorgeous:send(gorgeous.msgServerCreate, {name = username .. '\'s server'}, function(data)
    if data.success then  
      Overwatch:add(Server)
      self:join('localhost')
    end
  end)
end

function MenuMain:join(ip)
  serverIp = ip
  serverPort = 6061
  Overwatch:remove(ovw)
  Overwatch:add(Game)
  tick = 1
  love.keyboard.setKeyRepeat(false)
end

function MenuMain:play()
  gorgeous:send(gorgeous.msgMatchmake, {}, function(data)
    if #data.ip > 0 then self:join(data.ip)
    else print('No servers running :[') end
  end)
end