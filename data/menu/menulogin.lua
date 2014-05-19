MenuLogin = class()

local g = love.graphics
local w, h = g.width, g.height

function MenuLogin:load()
  ctx.ribbon.count = 3
  ctx.ribbon.margin = h(.1)

  ctx.input:clear()
  ctx.input:addInput('username', username or love.filesystem.read('username') or 'username')
  ctx.input:addInput('password', 'password')
end

function MenuLogin:mousepressed(x, y, button)
  local ribbon = ctx.ribbon:test(x, y)

  if ribbon == 1 then ctx.input:focusInput('username')
  elseif ribbon == 2 then ctx.input:focusInput('password')
  elseif ribbon == 3 then self:login() end
end

function MenuLogin:keyreleased(key)
  if key == 'return' then
    self:login()
  end
end

function MenuLogin:draw()
  local anchor = h(.3) + (h(.8) - h(.3)) / 2
  local input = ctx.input

  g.setFont('BebasNeue', h(.065))
  g.setColor(160, 160, 160)
  
  if input.focused == 'username' then g.setColor(220, 220, 220) else g.setColor(160, 160, 160) end
  g.printCenter('Username', w(.05), anchor - ctx.ribbon.margin, false, true)
  g.printCenter(input:val('username'), w(.4), anchor - ctx.ribbon.margin, false, true)
  
  if input.focused == 'password' then g.setColor(220, 220, 220) else g.setColor(160, 160, 160) end
  g.printCenter('Password', w(.05), anchor, false, true)
  g.printCenter(string.rep('•', #input:val('password')), w(.4), anchor, false, true)
  
  love.graphics.setColor(160, 160, 160)
  g.printCenter('Login', w(.05), anchor + h(.1), false, true)
end

function MenuLogin:login()
  username = ctx.input:val('username')
  ctx:push(ctx.main)
end
