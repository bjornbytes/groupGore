Draw = {}

local g = love.graphics

function Draw.rectCentered(style, x, y, w, h)
  local ox, oy = math.floor(x - (w / 2)), math.floor(y - (h / 2))
  g.rectangle(style, ox, oy, w, h)
end

function Draw.printCentered(str, x, y, h, v)
  local xx = x - ((h or (h == nil)) and (g.getFont():getWidth(str) / 2) or 0)
  local yy = y - ((v or (v == nil)) and (g.getFont():getHeight() / 2) or 0)
  g.print(str, xx, yy)
end