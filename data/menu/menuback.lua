MenuBack = class()

local g = love.graphics
local w, h = g.width, g.height

function MenuBack:draw()
  local pages = #ctx.pages > 1
  local x, y = love.mouse.getPosition()
  local hover = math.inside(x, y, 0, h(.8), w(), h(.2))
  if not pages then hover = false end
  g.setColor(0, 0, 0, hover and 120 or 80)
  g.rectangle('fill', 0, h(.8), w(), h(.2))
  if pages then
    g.setColor(hover and {255, 255, 255, 200} or {200, 200, 200, 200})
    g.setFont('BebasNeue', h(.065))
    g.printCenter('back', w(.05), h(.9), false, true)
  end
end

function MenuBack:mousepressed(x, y, button)
  if button == 'l' and math.inside(x, y, 0, h(.8), w(), h(.2)) then
    ctx:pop()
  end
end