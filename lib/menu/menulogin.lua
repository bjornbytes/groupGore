MenuLogin = extend(Overwatch)

function MenuLogin:init()
  self:addComponent(Input)
  
  local input = self:getComponent(Input)
  input:addInput('username', love.filesystem.read('username') or 'username')
  input:addInput('password', 'password')
  
  self.font = love.graphics.newFont('media/fonts/BebasNeue.ttf', h(.065))
end

function MenuLogin:mousepressed(x, y, button)
  local ribbon = self.overwatch:getComponent(MenuRibbon):test(x, y)
  local input = self:getComponent(Input)
  
  if ribbon == 1 then input:focusInput('username')
  elseif ribbon == 2 then input:focusInput('password')
  elseif ribbon == 3 then self:login() end
end

function MenuLogin:keyreleased(key)
  if key == 'return' then
    self:login()
  end
end

function MenuLogin:draw()
  local g = love.graphics
  
  local anchor = h(.3) + (h(.8) - h(.3)) / 2
  local input = self:getComponent(Input)

  g.setFont(self.font)
  g.setColor(160, 160, 160)
  
  if input.focused == 'username' then g.setColor(220, 220, 220) else g.setColor(160, 160, 160) end
  g.printCenter('Username', w(.05), anchor - h(.1), false, true)
  g.print(input:val('username'), w(.4), anchor - h(.1) - g.getFont():getHeight() / 2)
  
  if input.focused == 'password' then g.setColor(220, 220, 220) else g.setColor(160, 160, 160) end
  g.printCenter('Password', w(.05), anchor, false, true)
  g.print(string.rep('•', #input:val('password')), w(.4), anchor - g.getFont():getHeight() / 2)
  
  love.graphics.setColor(160, 160, 160)
  g.printCenter('Login', w(.05), anchor + h(.1), false, true)
end

function MenuLogin:login()
  local input = self:getComponent(Input)
  username = input:val('username')
  self.overwatch:removeComponent(MenuLogin)
  self.overwatch:addComponent(MenuMain)
end