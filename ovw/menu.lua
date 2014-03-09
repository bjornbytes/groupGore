local function w(x) x = x or 1 return love.window.getWidth() * x end
local function h(x) x = x or 1 return love.window.getHeight() * x end

--
MenuBackground = class()

function MenuBackground:init()
  self.bg = love.graphics.newImage('media/graphics/menu/ggbg.png')
end

function MenuBackground:draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(self.bg, 0, 0)
end

--
MenuRibbon = class()

function MenuRibbon:init()
  self.ribbons = {0, 0, 0, 0, 0}
  self.count = 3
end

function MenuRibbon:draw()
  local g = love.graphics
  local anchor = h(.3) + (h(.8) - h(.3)) / 2
  local fh = g.getFont():getHeight() / 2
  for i = 1, self.count do
    if math.inside(love.mouse.getX(), love.mouse.getY(), 0, anchor - (h(.1) * math.floor(self.count / 2)) + (h(.1) * (i - 1)) - fh, w(), fh * 2) then
      self.ribbons[i] = math.lerp(self.ribbons[i], 1, 10 * delta)
    else
      self.ribbons[i] = math.lerp(self.ribbons[i], 0, 20 * delta)
    end

    g.setColor(0, 0, 0, 80 * self.ribbons[i])
    g.rectangle('fill', 0, anchor - (h(.1) * math.floor(self.count / 2)) + (h(.1) * (i - 1)) - (fh * self.ribbons[i]), w(), fh * 2 * self.ribbons[i])
  end
end

--
MenuLogin = class()

function MenuLogin:init()
  self.username = love.filesystem.read('username') or 'username'
  self.password = 'password'
end

function MenuLogin:draw()
  local g = love.graphics
  local w2 = w(.5)
  local fh = h() * .025
  local ih, iw = fh * 1.6, w(.2)
    
  g:font('BebasNeue', 10)
  g.setColor(50, 50, 50)
  g.print('group', w(.6), h(.1) - g.getFont():getHeight() / 2)
  g.setColor(160, 160, 160)
  g.print('Gore', w(.6) + g.getFont():getWidth('group'), h(.1) - g.getFont():getHeight() / 2)
  
  g.setColor(0, 0, 0, 80)
  g.rectangle('fill', 0, h(.2), w(), h(.1))
  g.rectangle('fill', 0, h(.8), w(), h(.2))
  
  g:font('BebasNeue', 7)
  
  local anchor = h(.3) + (h(.8) - h(.3)) / 2
  g.setColor(160, 160, 160)
  Gooey.printCenter('Username', w(.05), anchor - h(.1), false, true)
  Gooey.printCenter('Password', w(.05), anchor, false, true)
  Gooey.printCenter('Login', w(.05), anchor + h(.1), false, true)
end

--
Menu = extend(Overwatch)

function Menu:init()
  self.gooey = Gooey()
  local g = self.gooey
    
  love.keyboard.setKeyRepeat(true)
  
  self:addComponent(MenuBackground)
  self:addComponent(MenuRibbon)
  self:addComponent(MenuLogin)
  
  self.update = self:run('update')
  self.draw = self:run('draw')
end

function Menu:host()
  gorgeous:send(gorgeous.msgServerCreate, {name = username .. '\'s server'}, function(data)
    if data.success then  
      Overwatch:add(Server)
      self:join('localhost')
    end
  end)
end

function Menu:join(ip)
  serverIp = ip
  serverPort = 6061
  Overwatch:remove(self)
  Overwatch:add(Game)
  tick = 1
  love.keyboard.setKeyRepeat(false)
end

function Menu:play()
  gorgeous:send(gorgeous.msgMatchmake, {}, function(data)
    if #data.ip > 0 then self:join(data.ip)
    else print('No servers running :[') end
  end)
end
