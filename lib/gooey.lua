Gooey = class()

local g = love.graphics
local function w(x) x = x or 1 return love.window.getWidth() * x end
local function h(x) x = x or 1 return love.window.getHeight() * x end

setmetatable(Gooey, {
  __index = function(t, k)
    local interps = rawget(t, 'interps')

    if interps then
      local i = rawget(t, 'interps')[k]
      if i then return i.current end
    end

    local r = rawget(t, k)
    if r then return r end

    return g[k]
  end,

  __newindex = function(t, k, v)
    local interps = rawget(t, 'interps')

    if interps then
      local i = rawget(t, 'interps')[k]
      if i then i.target = v return end
    end

    rawset(t, k, v)
  end
})

function Gooey:load()
  self.interps = {}
  self.align = {h = 'left', v = 'top'}
end

function Gooey:update()
  table.each(self.interps, function(v) v.current = math.lerp(v.current, v.target, .25) end)
end

function Gooey:background(obj, mode)
  if not obj then return end

  if not obj.type then love.graphics.setColor(obj)
  elseif obj.type() == 'Image' then
    mode = mode or 'stretch'
    if mode == 'stretch' then
      g.draw(self.background, 0, 0, 0, w() / self.background:getWidth(), h() / self.background:getHeight())
    end
  end
end

function Gooey:push(x, y)
  love.graphics.push()
  love.graphics.translate(-x, -y)
end

function Gooey:pop()
  love.graphics.pop()
end

function Gooey:align(h, v)
  self.align.h = h
  self.align.v = v or self.align.v
end

function Gooey:layout(x, y, w, h)
  --
end

function Gooey:interpolate(key, val)
  self.interps[key] = {current = val, target = val}
end

Gooey.col = love.graphics.setColor

function Gooey.rectangleCenter(style, x, y, w, h, pix)
  local ox, oy = math.round(x - (w / 2)), math.round(y - (h / 2))
  if pix then ox = ox + .5 oy = oy + .5 end
  g.rectangle(style, ox, oy, w, h)
end

function Gooey.printCenter(str, x, y, h, v)
  local xx = x - ((h or (h == nil)) and (g.getFont():getWidth(str) / 2) or 0)
  local yy = y - ((v or (v == nil)) and (g.getFont():getHeight() / 2) or 0)
  g.print(str, xx, yy)
end