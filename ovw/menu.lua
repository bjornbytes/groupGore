Menu = class()

local g = love.graphics
local col = g.setColor
local function w(x) x = x or 1 return love.window.getWidth() * x end
local function h(x) x = x or 1 return love.window.getHeight() * x end
local function drawRectangleCenter(style, x, y, w, h)
  g.rectangle(style, x - (w / 2), y - (h / 2), w, h)
end
local function printCenter(str, x, y, h, v)
  local xx = x - ((h or (h == nil)) and (g.getFont():getWidth(str) / 2) or 0)
  local yy = y - ((v or (v == nil)) and (g.getFont():getHeight() / 2) or 0)
  g.print(str, xx, yy)
end

function Menu:load()
  love.window.setMode(1280, 800, {borderless = true})

  self.font = g.newFont('/media/fonts/Ubuntu.ttf', h() * .02)
  self.headerFont = g.newFont('/media/fonts/Ubuntu.ttf', h() * .025)
  
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

  self.message = ''
  self.messageAlpha = 0
  
  self.buttons = {}

  love.keyboard.setKeyRepeat(true)
end

function Menu:unload()
  self.bg = nil
end

function Menu:update()
  if self.messageAlpha > 0 then self.messageAlpha = self.messageAlpha - (100 * tickRate) end
end

function Menu:draw()
  self.drawPage[self.page](self)
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
        self.message = 'Checking...'
        self.messageAlpha = 4000
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
          else
            self.message = 'Nope.'
            self.messageAlpha = 400
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
      local fh = self.font:getHeight()
      local ih = math.max(40, fh)
      local iw = math.max(w(.3), 240)
      if math.inside(x, y, w(.5) - (iw / 2), h(.35) - (ih / 2), iw, ih) then self:focusInput('username')
      elseif math.inside(x, y, w(.5) - (iw / 2), h(.35) + (ih / 2) + 1, iw, ih) then self:focusInput('password') end
    end
  elseif self.page == 'main' then
    if button == 'l' then
      if math.inside(x, y, w() - h(.0125) - h(.025), h(.0125), h(.025), h(.025)) then love.event.push('quit') end
      if self:testButton(1, 1, x, y) then
        --self.page = 'findServer'
        gorgeous:send(gorgeous.msgServerList, {}, function(data)
          table.print(data)
        end)
      end
      if self:testButton(1, 2, x, y) then self:host() end
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

Menu.drawPage = {}
Menu.drawPage['login'] = function(self)
  local w2, h35 = w(.5), h(.35)
  local fh = self.font:getHeight()
  local ih, iw = fh * 2, w(.2)
  
  self:drawBackground()
  self:drawLogo(h(.02), h(.02))
  
  g.setFont(self.font)
  self:drawInput('username', w2, h35)
  self:drawInput('password', w2, h35 + ih + 1)

  if self.messageAlpha > 0 then
    col(255, 255, 255, math.min(self.messageAlpha, 255) * .6)
    printCenter(self.message, w2, h(.5))
  end
end

Menu.drawPage['main'] = function(self)
  self:drawBackground()
  self:drawHeader()
  
  self:drawButton(1, 1, 'Find Server')
  self:drawButton(2, 1.5, 'Quick Play')
  self:drawButton(1, 2, 'Create Server')
  self:drawButton(3, 1, 'Much Buttons')
  self:drawButton(3, 2, 'Wow')
end

function Menu:drawBackground()
  col(255, 255, 255)
  g.draw(self.bg, 0, 0, 0, love.window.getWidth() / self.bg:getWidth(), love.window.getHeight() / self.bg:getHeight())
end

function Menu:drawLogo(x, y)
  g.setFont(self.headerFont)
  col(108, 89, 128)
  g.print('g', x, y)
  col(140, 107, 84)
  g.print('G', x + self.headerFont:getWidth('g'), y)
end

function Menu:drawHeader()
  local h25, h125 = h(.025), h(.0125)
  
  col(0, 0, 0, 100)
  g.rectangle('fill', 0, 0, w(), h(.05))
  col(108, 89, 128, 160)
  g.line(0, h(.05), w(), h(.05))
  
  col(108, 89, 128)
  g.setFont(self.headerFont)
  printCenter(username, h125, h25, false, true)
  
  col(140, 107, 84)
  g.setFont(self.headerFont)
  self:drawLogo(w(.5) - self.headerFont:getWidth('gG') / 2, h(.025) - self.headerFont:getHeight() / 2)
  
  col(140, 107, 84, 255)
  g.rectangle('line', w() - h125 - h25, h125, h25, h25)
  g.rectangle('line', w() - (2 * h125) - (2 * h25), h125, h25, h25)
end

function Menu:drawButton(x, y, str)
  local bw = w(.15)
  local bh = h(.06)
  col(0, 0, 0, 100)
  drawRectangleCenter('fill', w(.5) - w(.18) + ((x - 1) * w(.18)), h(.5) - h(.04) + ((y - 1) * h(.08)), bw, bh)
  col(108, 89, 128, 160)
  drawRectangleCenter('line', w(.5) - w(.18) + ((x - 1) * w(.18)), h(.5) - h(.04) + ((y - 1) * h(.08)), bw, bh)
  col(140, 107, 84, 255)
  printCenter(str, w(.5) - w(.18) + ((x - 1) * w(.18)), h(.5) - h(.04) + ((y - 1) * h(.08)))
end

function Menu:testButton(x, y, mx, my)
  return math.inside(mx, my, w(.5) - w(.18) + ((x - 1) * w(.18)) - w(.075), h(.5) - h(.04) + ((y - 1) * h(.08)) - h(.03), w(.15), h(.06))
end

function Menu:drawInput(key, x, y)
  local fh = g.getFont():getHeight()
  local iw, ih = w(.2), fh * 2
  
  col(0, 0, 0, 120)
  drawRectangleCenter('fill', x, y, iw, ih)
  
  col(112, 85, 67)
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