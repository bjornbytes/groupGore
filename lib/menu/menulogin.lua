MenuLogin = class()

function MenuLogin:init()
  ovw.input:addInput('username', love.filesystem.read('username') or 'username')
  ovw.input:addInput('password', 'password')
  
  self.font = love.graphics.newFont('media/fonts/BebasNeue.ttf', h(.065))
end

function MenuLogin:load()
  ovw.ribbon.count = 3
  ovw.ribbon.margin = h(.1)
end

function MenuLogin:mousepressed(x, y, button)
  local ribbon = ovw.ribbon:test(x, y)
  
  if ribbon == 1 then ovw.input:focusInput('username')
  elseif ribbon == 2 then ovw.input:focusInput('password')
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
  local input = ovw.input

  g.setFont(self.font)
  g.setColor(160, 160, 160)
  
  if input.focused == 'username' then g.setColor(220, 220, 220) else g.setColor(160, 160, 160) end
  g.printCenter('Username', w(.05), anchor - ovw.ribbon.margin, false, true)
  g.printCenter(input:val('username'), w(.4), anchor - ovw.ribbon.margin, false, true)
  
  if input.focused == 'password' then g.setColor(220, 220, 220) else g.setColor(160, 160, 160) end
  g.printCenter('Password', w(.05), anchor, false, true)
  g.printCenter(string.rep('•', #input:val('password')), w(.4), anchor, false, true)
  
  love.graphics.setColor(160, 160, 160)
  g.printCenter('Login', w(.05), anchor + h(.1), false, true)
end

function MenuLogin:login()
  username = ovw.input:val('username')
  ovw:changePage(ovw.main)
end