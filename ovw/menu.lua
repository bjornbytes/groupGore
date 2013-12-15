Menu = class()

local function w(x) x = x or 1 return love.window.getWidth() * x end
local function h(x) x = x or 1 return love.window.getHeight() * x end

function Menu:load()
  love.window.setMode(1280, 800)

  self.font = love.graphics.newFont('/media/fonts/Ubuntu.ttf', h() * .02)
  self.titleFont = love.graphics.newFont('/media/fonts/Ubuntu.ttf', h() * .025)
  
  self.bg = love.graphics.newImage('/media/graphics/menu/bgMenu.jpeg')
  
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

  love.keyboard.setKeyRepeat(true)
end

function Menu:unload()
  self.bg = nil
end

function Menu:update()
  if self.messageAlpha > 0 then self.messageAlpha = self.messageAlpha - (100 * tickRate) end
end

function Menu:draw()
  love.graphics.setColor(50, 50, 55)
  love.graphics.rectangle('fill', 0, 0, love.window.getWidth(), love.window.getHeight())
  
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(self.bg, 0, 0, 0, love.window.getWidth() / self.bg:getWidth(), love.window.getHeight() / self.bg:getHeight())
  
  if self.page == 'login' then    
    love.graphics.setFont(self.titleFont)
    love.graphics.setColor(108, 89, 128)
    love.graphics.print('g', h(.01), h(.01))
    love.graphics.setColor(140, 107, 84)
    love.graphics.print('G', h(.01) + self.titleFont:getWidth('g'), h(.01))
    
    love.graphics.setFont(self.font)
    local fh = self.font:getHeight()
    local ih = math.max(40, fh)
    local iw = math.max(w(.3), 240)
    love.graphics.setColor(20, 22, 24)
    love.graphics.rectangle('fill', w(.5) - (iw / 2), h(.35) - (ih / 2), iw, ih)
    love.graphics.rectangle('fill', w(.5) - (iw / 2), h(.35) + (ih / 2) + 1, iw, ih)
    
    love.graphics.setColor(112, 85, 67)
    love.graphics.print(self.username, w(.5) - (iw / 2) + (fh / 2), h(.35) - (fh / 2))
    if self.focused == 'username' then
      love.graphics.line(w(.5) - (iw / 2) + (fh / 2) + self.font:getWidth(self.username) + 1, h(.35) - (fh / 2), w(.5) - (iw / 2) + (fh / 2) + self.font:getWidth(self.username) + 1, h(.35) - (fh / 2) + fh)
    end
    love.graphics.print(string.rep('•', #self.password), w(.5) - (iw / 2) + (fh / 2), h(.35) - (fh / 2) + ih + 1)
    if self.focused == 'password' then
      love.graphics.line(w(.5) - (iw / 2) + (fh / 2) + self.font:getWidth(string.rep('•', #self.password)) + 1, h(.35) - (fh / 2) + ih + 1, w(.5) - (iw / 2) + (fh / 2) + self.font:getWidth(string.rep('•', #self.password)) + 1, h(.35) - (fh / 2) + ih + 1 + fh)
    end

    if self.messageAlpha > 0 then
      love.graphics.setColor(255, 255, 255, math.min(self.messageAlpha, 255) * .6)
      love.graphics.print(self.message, w(.5) - self.font:getWidth(self.message) / 2, h(.5))
    end
  elseif self.page == 'main' then
    love.graphics.setColor(0, 0, 0, 120)
    love.graphics.rectangle('fill', 0, 0, w(), h(.05))
    
    love.graphics.setFont(self.titleFont)
    love.graphics.setColor(108, 89, 128)
    love.graphics.print('g', h(.01), h(.01))
    love.graphics.setColor(140, 107, 84)
    love.graphics.print('G', h(.01) + self.titleFont:getWidth('g'), h(.01))
    
    love.graphics.setFont(self.font)
    local fh = self.font:getHeight()
    local ih = math.max(40, fh)
    local iw = math.max(w(.3), 240)
    love.graphics.setColor(30, 30, 30)
    love.graphics.rectangle('fill', w(.5) - (iw / 2), h(.35) - (ih / 2), iw, ih)
    
    love.graphics.setColor(112, 85, 67)
    love.graphics.print(self.ip, w(.5) - (iw / 2) + (fh / 2), h(.35) - (fh / 2))
    if self.focused == 'ip' then
      love.graphics.line(w(.5) - (iw / 2) + (fh / 2) + self.font:getWidth(self.ip) + 1, h(.35) - (fh / 2), w(.5) - (iw / 2) + (fh / 2) + self.font:getWidth(self.ip) + 1, h(.35) - (fh / 2) + fh)
    end
  end
end

function Menu:textinput(character)
  if self.page == 'login' then
    if self.focused == 'username' then
      if character:match('%w') then self.username = self.username .. character end
    elseif self.focused == 'password' then
      if character:match('%w') then self.password = self.password .. character end
    end
  elseif self.page == 'main' then
    if self.focused == 'ip' then
      if character:match('[0-9%.]') then self.ip = self.ip .. character end
    end
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
  elseif self.page == 'main' then
    if key == 'return' then
      local function enter()
        serverip = self.ip
        serverPort = 6061
        Overwatch:remove(self)
        Overwatch:add(Game)
        tick = 1
        love.keyboard.setKeyRepeat(false)
      end

      if love.keyboard.isDown('rshift') then
        gorgeous:send(gorgeous.msgCreateServer, {}, function(data)
          if data.success then
            Overwatch:add(Server)
            enter()
          else
            self.message = 'Unable to create server.'
            self.messageAlpha = 400
          end
        end)
      else
        enter()
      end
    elseif key == 'v' and love.keyboard.isDown('lctrl') then
      self.ip = love.system.getClipboardText()
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
      local fh = self.font:getHeight()
      local ih = math.max(40, fh)
      local iw = math.max(w(.3), 240)
      if math.inside(x, y, w(.5) - (iw / 2), h(.35) - (ih / 2), iw, ih) then self:focusInput('ip') end
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
