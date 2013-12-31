Menu = class()

local g = love.graphics
local d = Draw
local col = g.setColor
local function w(x) x = x or 1 return love.window.getWidth() * x end
local function h(x) x = x or 1 return love.window.getHeight() * x end

function Menu:load()
  do
    local w, h = love.window.getDesktopDimensions()
    w, h = w * .8, h * .8
    love.window.setMode(w, h, {borderless = false, resizable = true})
  end

  self.bigFont = g.newFont('media/fonts/coolvetica.ttf', h() * .08)
  self.smallFont = g.newFont('media/fonts/aeroMatics.ttf', h() * .025)
  self.buttonFont = g.newFont('media/fonts/aeroMatics.ttf', h() * .04)

  self.bg = g.newImage('/media/graphics/menu/bgMenu.jpeg')
  
  self.page = 'login'
  self.focused = nil

  self.ip = '127.0.0.1'
  local clip = love.system.getClipboardText()
  if clip:match('^[0-9]+%.[0-9]+%.[0-9]+%.[0-9]+$') then self.ip = clip end
  
  self.username = love.filesystem.read('username') or 'username'
  self.password = 'password'
  self.ipDefault = nil
  self.usernameDefault = self.username
  self.passwordDefault = self.password
  
  self.buttons = {}
  
  self.boxWidth = w(.26875)
  self.boxHeight = h(.285)
  self.targetBoxWidth = self.boxWidth
  self.targetBoxHeight = self.boxHeight
  self.prevBoxWidth = self.boxWidth
  self.prevBoxHeight = self.boxHeight

  love.keyboard.setKeyRepeat(true)
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
  self.drawPage[self.page](self)
  self.boxWidth, self.boxHeight = bw, bh
end

function Menu:textinput(character)
  if self.page == 'login' then
    if self.focused == 'username' then
      if character:match('%w') then self.username = self.username .. character end
    elseif self.focused == 'password' then
      if character:match('%w') then self.password = self.password .. character end
    end
  elseif self.page == 'main' then
    --
  end
end

function Menu:keypressed(key)
  if key == 'escape' then love.event.quit() return
  elseif key == 'backspace' and self.focused then
    self[self.focused] = self[self.focused]:sub(1, -2)
    return
  end

  if self.page == 'login' then
    if self.focused == 'username' then
      if key == 'tab' then self:focusInput('password') end
    elseif self.focused == 'password' then
      if key == 'tab' then self:focusInput('username')
      elseif key == 'return' then
        gorgeous:send(gorgeous.msgLogin, {
          username = self.username,
          password = self.password
        }, function(data)
          if data.success then
            username = self.username
            password = self.password
            self.page = 'main'
            self:focusInput('ip')
            
            love.filesystem.write('username', username)
          end
        end)
      end
    end
  end
end

function Menu:mousepressed(x, y, button)
  self:unfocus()
  if self.page == 'login' then
    if button == 'l' then
      local fh = self.smallFont:getHeight()
      local ih = fh * 1.6
      local iw = w(.2)
      
      if math.inside(x, y, w(.5) - (iw / 2), h(.5) - (self.boxHeight / 2) + (.33 * self.boxHeight) - (ih / 2), iw, ih) then self:focusInput('username')
      elseif math.inside(x, y, w(.5) - (iw / 2), h(.5) - (self.boxHeight / 2) + (.67 * self.boxHeight) - (ih / 2), iw, ih) then self:focusInput('password') end
    end
  elseif self.page == 'main' then
    if button == 'l' then
      if math.inside(x, y, 4, 4, 20, 20) then self:host() end
      if self:testButton(x, y, w(.5), h(.5) - (self.boxHeight / 2) + (.2 * self.boxHeight)) then self:play() end
      if self:testButton(x, y, w(.5), h(.5) - (self.boxHeight / 2) + (.8 * self.boxHeight)) then love.event.push('quit') end
    end
  end
end

function Menu:focusInput(key)
  self:unfocus()
  self.focused = key
  if self[self.focused .. 'Default'] and self[self.focused] == self[self.focused .. 'Default'] then self[self.focused] = '' end
end

function Menu:unfocus()
  if not self.focused then return end
  if self[self.focused] == '' and self[self.focused .. 'Default'] then self[self.focused] = self[self.focused .. 'Default'] end
  self.focused = nil
end

function Menu:resize()
  self.bigFont = g.newFont('media/fonts/coolvetica.ttf', h() * .08)
  self.smallFont = g.newFont('media/fonts/aeroMatics.ttf', h() * .025)
  self.buttonFont = g.newFont('media/fonts/aeroMatics.ttf', h() * .04)
end

Menu.drawPage = {}
Menu.drawPage['login'] = function(self)
  local w2 = w(.5)
  local fh = self.smallFont:getHeight()
  local ih, iw = fh * 1.6, w(.2)
  
  self.targetBoxWidth = w(.26875)
  self.targetBoxHeight = h(.285)
  
  self:drawBackground()
  self:drawBox()

  g.setFont(self.smallFont)
  if gorgeous then  
    self:drawInput('username', w2, h(.5) - (self.boxHeight / 2) + (.33 * self.boxHeight))
    self:drawInput('password', w2, h(.5) - (self.boxHeight / 2) + (.67 * self.boxHeight))
  else
    Gooey.printCenter('Can\'t connect to gorgeous =(', w(.5), h(.5))
  end
end

Menu.drawPage['main'] = function(self)
  self.targetBoxWidth = w()
  self.targetBoxHeight = h(.82)

  self:drawBackground()
  self:drawBox()
  self:drawUsername()
  --[[self:drawIcons()
  
  self:drawButton('Play', w(.5), h(.5) - (self.boxHeight / 2) + (.2 * self.boxHeight))
  self:drawButton('Stats', w(.5), h(.5) - (self.boxHeight / 2) + (.4 * self.boxHeight))
  self:drawButton('Options', w(.5), h(.5) - (self.boxHeight / 2) + (.6 * self.boxHeight))
  self:drawButton('Exit', w(.5), h(.5) - (self.boxHeight / 2) + (.8 * self.boxHeight))]]
end

function Menu:drawBackground()
  col(255, 255, 255)
  g.draw(self.bg, 0, 0, 0, love.window.getWidth() / self.bg:getWidth(), love.window.getHeight() / self.bg:getHeight())
end

function Menu:drawLogo()
  g.setFont(self.bigFont)
  local x = w(.5) + (self.boxWidth / 2) - g.getFont():getWidth('groupGore')
  local y = h(.5) - (self.boxHeight / 2) - g.getFont():getAscent() - 1
  col(108, 89, 128)
  g.print('group', x - 20, y)
  col(140, 107, 84)
  g.print('Gore', x + g.getFont():getWidth('group') - 20, y)
  y = y + 120
end

function Menu:drawBox()
  col(0, 0, 0, 140)
  Gooey.rectangleCenter('fill', w(.5), h(.5), self.boxWidth, self.boxHeight)
  col(255, 255, 255, 40)
  Gooey.rectangleCenter('line', w(.5), h(.5), self.boxWidth, self.boxHeight)
  self:drawLogo()
end

function Menu:drawUsername()
  g.setFont(self.smallFont)
  col(255, 255, 255, 255)
  local x = w(.5) - (self.boxWidth / 2)
  local y = h(.5) - (self.boxHeight / 2) - g.getFont():getAscent() - 1
  g.print(self.username, x, y)
end

function Menu:drawIcons()
  for i = 1, 3 do
    col(0, 0, 0, 100)
    g.rectangle('fill', 4 + ((i - 1) * 24), 4, 20, 20)
    col(140, 107, 84)
    g.rectangle('line', 4 + ((i - 1) * 24), 4, 20, 20)
  end
end

function Menu:drawButton(str, x, y)
  g.setFont(self.buttonFont)
  col(51, 49, 54, 160)
  Gooey.rectangleCenter('fill', x, y, w(.15), h(.08))
  col(51, 49, 54, 255)
  Gooey.rectangleCenter('line', x, y, w(.15), h(.08))
  col(255, 255, 255, 200)
  Gooey.printCenter(str, x, y)
end

function Menu:testButton(mx, my, x, y)
  return math.inside(mx, my, x - (w(.15) / 2), y - (h(.08) / 2), w(.15), h(.08))
end

function Menu:drawInput(key, x, y)
  local fh = g.getFont():getHeight()
  local iw, ih = w(.2), fh * 1.6
  
  col(51, 49, 54, 160)
  Gooey.rectangleCenter('fill', x, y, iw, ih)
  col(51, 49, 54, 255)
  Gooey.rectangleCenter('line', x, y, iw, ih)
  
  col(140, 107, 84)
  local str = self[key]
  if key == 'password' then str = string.rep('•', #str) end
  g.print(str, x - (iw / 2) + (fh / 2), y - (fh / 2))
  if self.focused == key then
    g.line(x - (iw / 2) + (fh / 2) + g.getFont():getWidth(str) + 1, y - (fh / 2), x - (iw / 2) + (fh / 2) + g.getFont():getWidth(str) + 1, y - (fh / 2) + fh)
  end
end

function Menu:host()
  gorgeous:send(gorgeous.msgServerCreate, {name = username .. '\'s server'}, function(data)
    if data.success then
      Overwatch:add(Server)
      self:join()
    end
  end)
end

function Menu:join()
  serverIp = self.ip
  serverPort = 6061
  Overwatch:remove(self)
  Overwatch:add(Game)
  tick = 1
  love.keyboard.setKeyRepeat(false)
end

function Menu:play()
  gorgeous:send(gorgeous.msgMatchmake, {}, function(data)
    if #data.ip > 0 then
      self.ip = data.ip
      self:join()
    else
      print('No servers running :[')
    end
  end)
end