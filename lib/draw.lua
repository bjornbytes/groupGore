Draw = {}

local g = love.graphics

function Draw.rectCentered(style, x, y, w, h, pix)
  local ox, oy = math.round(x - (w / 2)), math.round(y - (h / 2))
  if pix then ox = ox + .5 oy = oy + .5 end
  g.rectangle(style, ox, oy, w, h)
end

function Draw.printCentered(str, x, y, h, v)
  local xx = x - ((h or (h == nil)) and (g.getFont():getWidth(str) / 2) or 0)
  local yy = y - ((v or (v == nil)) and (g.getFont():getHeight() / 2) or 0)
  g.print(str, xx, yy)
end