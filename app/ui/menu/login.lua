local Login = class()

local g = love.graphics

function Login:activate()
  ctx.ribbon.count = 2
  ctx.ribbon.margin = .1

  ctx.input:clear()
  ctx.input:add('username', username or love.filesystem.read('username') or 'nick')
end

function Login:draw()
  local u, v = ctx.u, ctx.v
  local anchor = (.3 + (.8 - .3) / 2) * v
  local input = ctx.input

  g.setFont('BebasNeue', .065 * v)
  g.setColor(160, 160, 160)

  if input.focused == 'username' then g.setColor(220, 220, 220) else g.setColor(160, 160, 160) end
  g.printCenter('Nickname', u * .05, anchor - ctx.ribbon.margin * v / 2, false, true)
  g.printCenter(input:val('username'), .4 * u, anchor - ctx.ribbon.margin * v / 2, false, true)

  --[[if input.focused == 'password' then g.setColor(220, 220, 220) else g.setColor(160, 160, 160) end
  g.printCenter('Password', w(.05), anchor, false, true)
  g.printCenter(string.rep('•', #input:val('password')), w(.4), anchor, false, true)]]

  love.graphics.setColor(160, 160, 160)
  g.printCenter('Enter', .05 * u, anchor + ctx.ribbon.margin * v / 2, false, true)
end

function Login:mousepressed(x, y, button)
  local ribbon = ctx.ribbon:test(x, y)

  if ribbon == 1 then ctx.input:focus('username')
  elseif ribbon == 2 then self:login() end
end

function Login:keypressed(key)
  if key == 'return' then self:login()
  elseif key == 'backspace' and self.focused then
    self[self.focused] = self[self.focused]:sub(1, -2)
  end
end

function Login:textinput(char)
  if self.focused then
    self[self.focused] = self[self.focused] .. char
  end
end

function Login:login()
  local username = ctx.input:val('username')
  if #username == 0 then return end

  local success = app.net.goregous:login(username)
  if success then
    _G['username'] = username
    ctx.user.username = username
    ctx:push('main')
  else
    ctx.alert:show('Problem logging in.')
  end
end

return Login
