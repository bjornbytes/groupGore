MenuLogin = class()

local g = love.graphics
local w, h = g.width, g.height

function MenuLogin:load()
  ctx.ribbon.count = 2
  ctx.ribbon.margin = h(.1)

  ctx.input:clear()
  ctx.input:addInput('nickname', username or love.filesystem.read('username') or 'nick')
end

function MenuLogin:mousepressed(x, y, button)
  local ribbon = ctx.ribbon:test(x, y)

  if ribbon == 1 then ctx.input:focusInput('nickname')
  elseif ribbon == 2 then self:login() end
end

function MenuLogin:keypressed(key)
  if key == 'return' then self:login() end
end

function MenuLogin:draw()
  local anchor = h(.3) + (h(.8) - h(.3)) / 2
  local input = ctx.input

  g.setFont('BebasNeue', h(.065))
  g.setColor(160, 160, 160)
  
  if input.focused == 'nickname' then g.setColor(220, 220, 220) else g.setColor(160, 160, 160) end
  g.printCenter('Nickname', w(.05), anchor - ctx.ribbon.margin / 2, false, true)
  g.printCenter(input:val('nickname'), w(.4), anchor - ctx.ribbon.margin / 2, false, true)
  
  --[[if input.focused == 'password' then g.setColor(220, 220, 220) else g.setColor(160, 160, 160) end
  g.printCenter('Password', w(.05), anchor, false, true)
  g.printCenter(string.rep('•', #input:val('password')), w(.4), anchor, false, true)]]
  
  love.graphics.setColor(160, 160, 160)
  g.printCenter('Enter', w(.05), anchor + ctx.ribbon.margin / 2, false, true)
end

function MenuLogin:login()
  local text = ctx.input:val('nickname')
  if #text == 0 then return end

  love.thread.getChannel('goregous.in'):push({'login', text})
  ctx.loader:activate('Logging in')
end
