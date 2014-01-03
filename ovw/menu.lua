Menu = class()

local function w(x) x = x or 1 return love.window.getWidth() * x end
local function h(x) x = x or 1 return love.window.getHeight() * x end

function Menu:load()
  do
    local w, h = love.window.getDesktopDimensions()
    w, h = w * .8, h * .8
    love.window.setMode(w, h, {borderless = false, resizable = true})
  end

  self.gooey = Gooey()
  local g = self.gooey

  self.bg = g.newImage('/media/graphics/menu/bgMenu.jpeg')
  
  self.page = 'login'
  
  local username = love.filesystem.read('username') or 'username'
  g:addInput('username', username)
  g:addInput('password', 'password')
  
  self.boxWidth = w(.26875)
  self.boxHeight = h(.285)
  self.targetBoxWidth = self.boxWidth
  self.targetBoxHeight = self.boxHeight
  self.prevBoxWidth = self.boxWidth
  self.prevBoxHeight = self.boxHeight

  love.keyboard.setKeyRepeat(true)
  if username ~= 'username' then g:focus('password') end
end

function Menu:unload()
  self.bg = nil
end

function Menu:update()
  self.prevBoxWidth = self.boxWidth
  self.prevBoxHeight = self.boxHeight
  self.boxWidth = math.lerp(self.boxWidth, self.targetBoxWidth, .25)
  self.boxHeight = math.lerp(self.boxHeight, self.targetBoxHeight, .25)
end

function Menu:draw()
  local bw, bh = self.boxWidth, self.boxHeight
  self.boxWidth = math.lerp(self.prevBoxWidth, self.boxWidth, tickDelta / tickRate)
  self.boxHeight = math.lerp(self.prevBoxHeight, self.boxHeight, tickDelta / tickRate)
  if self.page then self.drawPage[self.page](self) end
  if self.modalType then self.drawModal[self.modalType](self) end
  self.boxWidth, self.boxHeight = bw, bh
end

function Menu:textinput(character)
  return self.gooey:textinput(character)
end

function Menu:keypressed(key)
  self.gooey:keypressed(key)

  if key == 'escape' then love.event.quit() return end

  if self.page == 'login' then
    if self.gooey.focused == 'username' then
      if key == 'tab' then self.gooey:focus('password') end
    elseif self.gooey.focused == 'password' then
      if key == 'tab' then self.gooey:focus('username')
      elseif key == 'return' then
        gorgeous:send(gorgeous.msgLogin, {
          username = self.gooey.inputs['username'].val,
          password = self.gooey.inputs['password'].val
        }, function(data)
          if data.success then
            username = self.gooey.inputs['username'].val
            password = self.gooey.inputs['password'].val
            self.page = 'main'

            love.filesystem.write('username', username)
          end
        end)
      end
    end
  elseif self.page == 'main' then
    if key == 'return' then self:host() end
  end
end

function Menu:mousepressed(x, y, button)
  if self.page == 'login' then
    if button == 'l' then
      local fh = h() * .025
      local ih = fh * 1.6
      local iw = w(.2)
    end
  elseif self.page == 'main' then
    if button == 'l' then
      if math.inside(x, y, 4, 4, 20, 20) then self:host() end
      if self:testButton(x, y, w(.5), h(.5) - (self.boxHeight / 2) + (.2 * self.boxHeight)) then self:play() end
      if self:testButton(x, y, w(.5), h(.5) - (self.boxHeight / 2) + (.8 * self.boxHeight)) then love.event.push('quit') end
    end
  end
end


function Menu:resize()
  self.gooey:resize()
end

Menu.drawPage = {}
Menu.drawPage['login'] = function(self)
  local g = self.gooey
  local w2 = w(.5)
  local fh = h() * .025
  local ih, iw = fh * 1.6, w(.2)
  
  self.targetBoxWidth = w(.26875)
  self.targetBoxHeight = h(.285)
  
  g.background(self.bg)
  self:drawBox()

  g:font('aeromatics', 2.5)
  if gorgeous then  
    g:drawInput('username', w2, h(.5) - (self.boxHeight / 2) + (.33 * self.boxHeight))
    g:drawInput('password', w2, h(.5) - (self.boxHeight / 2) + (.67 * self.boxHeight))
  end
end

Menu.drawPage['main'] = function(self)
  local g = self.gooey
  self.targetBoxWidth = w(.9)
  self.targetBoxHeight = h(.82)

  g.background(self.bg)
  self:drawBox()
  self:drawUsername()
  self:drawIcons()
  
  self:drawButton('Play', w(.5), h(.5) - (self.boxHeight / 2) + (.2 * self.boxHeight))
  self:drawButton('Stats', w(.5), h(.5) - (self.boxHeight / 2) + (.4 * self.boxHeight))
  self:drawButton('Options', w(.5), h(.5) - (self.boxHeight / 2) + (.6 * self.boxHeight))
  self:drawButton('Exit', w(.5), h(.5) - (self.boxHeight / 2) + (.8 * self.boxHeight))
end

function Menu:drawLogo()
  local g = self.gooey
  g:font('coolvetica', 8)
  local x = w(.5) + (self.boxWidth / 2) - g.getFont():getWidth('groupGore')
  local y = h(.5) - (self.boxHeight / 2) - g.getFont():getAscent() - 1
  g.setColor(108, 89, 128)
  g.print('group', x - 2, y)
  g.setColor(140, 107, 84)
  g.print('Gore', x + g.getFont():getWidth('group') - 2, y)
  y = y + 120
end

function Menu:drawBox()
  local g = self.gooey
  g.setColor(0, 2, 4, 140)
  g.rectangleCenter('fill', w(.5), h(.5), self.boxWidth, self.boxHeight)
  g.setColor(255, 255, 255, 40)
  g.rectangleCenter('line', w(.5), h(.5), self.boxWidth, self.boxHeight)
  self:drawLogo()
end

function Menu:drawUsername()
  local g = self.gooey
  g:font('aeromatics', 2.5)
  g.setColor(255, 255, 255, 255)
  local x = w(.5) - (self.boxWidth / 2)
  local y = h(.5) - (self.boxHeight / 2) - g.getFont():getAscent() - 1
  g.print(username, x, y)
end

function Menu:drawIcons()
  local g = self.gooey
  for i = 1, 3 do
    g.setColor(0, 0, 0, 100)
    g.rectangle('fill', 4 + ((i - 1) * 24), 4, 20, 20)
    g.setColor(140, 107, 84)
    g.rectangle('line', 4 + ((i - 1) * 24), 4, 20, 20)
  end
end

function Menu:drawButton(str, x, y)
  local g = self.gooey
  g:font('aeromatics', 4)
  g.setColor(100, 0, 0, 50)
  g.rectangleCenter('fill', x, y, w(.15), h(.08))
  g.setColor(200, 50, 50, 150)
  g.rectangleCenter('line', x, y, w(.15), h(.08))
  g.setColor(255, 255, 255, 200)
  g.printCenter(str, x, y)
end

function Menu:testButton(mx, my, x, y)
  return math.inside(mx, my, x - (w(.15) / 2), y - (h(.08) / 2), w(.15), h(.08))
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