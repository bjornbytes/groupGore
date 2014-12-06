MenuBack = class()

local g = love.graphics

function MenuBack:draw()
  local u, v = ctx.u, ctx.v
  local active = ctx.page and ctx.page ~= 'login' and ctx.page ~= 'main'
  local mx, my = love.mouse.getPosition()
  local hover = math.inside(mx, my, 0, .8 * v, u, .2 * v)
  if not active then hover = false end
  g.setColor(0, 0, 0, hover and 120 or 80)
  g.rectangle('fill', 0, .8 * v, u, .2 * v)
  if active then
    g.setColor(hover and {255, 255, 255, 200} or {200, 200, 200, 200})
    g.setFont('BebasNeue', .065 * v)
    g.printCenter('back', .05 * u, .9 * v, false, true)
  end
end

function MenuBack:mousereleased(x, y, button)
  local u, v = ctx.u, ctx.v
  if button == 'l' and math.inside(x, y, 0, .8 * v, u, .2 * v) then
    ctx:push('main')
    data.media.sounds.click:play()
  end
end
