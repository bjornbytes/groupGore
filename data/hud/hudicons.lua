HudIcons = class()

local g = love.graphics
local w, h = g.width, g.height

function HudIcons:init()
  self.prevLabelAlphas = {}
  self.labelAlphas = {}
  for i = 1, 5 do
    self.prevLabelAlphas[i] = 0
    self.labelAlphas[i] = 0
  end
end

function HudIcons:update()
  local p = ctx.players:get(ctx.id)
  if p then
    for i = 1, 5 do
      self.prevLabelAlphas[i] = self.labelAlphas[i]
      if p.weapon == i or p.skill == i then
        self.labelAlphas[i] = math.lerp(self.labelAlphas[i], 1, math.min(10 * tickRate, 1))
      elseif p.slots[i].type == 'passive' then
        self.labelAlphas[i] = math.lerp(self.labelAlphas[i], .5, math.min(10 * tickRate, 1))
      else
        self.labelAlphas[i] = math.lerp(self.labelAlphas[i], .5, math.min(10 * tickRate, 1))
      end
    end
  end
end

function HudIcons:draw()
  local top = h(.1)
  local p = ctx.players:get(ctx.id)
  if p then
    local width = data.media.graphics.icons[p.slots[1].code]:getWidth()
    local s = g.minUnit(.08) / width
    for i = 1, 5 do
      local icon = data.media.graphics.icons[p.slots[i].code]
      local alpha = math.min(math.lerp(self.prevLabelAlphas[i], self.labelAlphas[i], tickDelta / tickRate), 1) * 200
      local iconx = w(.5) - g.minUnit(.213) + g.minUnit(.1065 * (i - 1))
      g.setColor(255, 255, 255, math.max(alpha, 100) * (255 / 200))
      g.draw(icon, iconx - (width * s / 2), top, 0, s, s)

      local prc = 0      
      if p.slots[i].value then
        prc = p.slots[i].value(p.slots[i], p) * 100
      end

      g.setColor(0, 0, 0, 128)
      local x, y = iconx, top
      
      local points = {}
      local function insert(x, y)
        table.insert(points, x)
        table.insert(points, y + 1)
      end
      
      insert(x, y + (width * s / 2))
      insert(x, y)
      
      local function halp(val, xx, yy)
        if prc > val then
          x = x + (xx * s)--w(xx / 800)
          y = y + (yy * s)--w(yy / 800)
          prc = prc - val
          insert(x, y)
          return false
        else
          x = x + ((prc / val) * (xx * s))--w(xx / 800))
          y = y + ((prc / val) * (yy * s))--w(yy / 800))
          insert(x, y)
          return true
        end
      end
      
      while true do
        if halp(10.21, -18, 0) then break end
        if halp(4.25, -5, 5) then break end
        if halp(19.82, 0, 33) then break end
        if halp(6.35, 6, 6) then break end
        if halp(19.22, 34, 0) then break end
        if halp(6.35, 6, -6) then break end
        if halp(19.82, 0, -33) then break end
        if halp(3.4, -5, -5) then break end
        if halp(11.41, -19, 0) then break end
        break
      end
      
      g.polygon('fill', points)
      
      g.setFont('pixel', 8)
      local str = p.slots[i].name
      if p.slots[i].type == 'passive' then str = '[' .. str .. ']' end
      local strw, strh = g.getFont():getWidth(str), g.getFont():getHeight()
      
      g.setColor(0, 0, 0, alpha)
      g.rectangle('fill', iconx - ((strw + 3) / 2), top + (width * s) + 1, strw + 3, strh + 2)
      
      if p.slots[i].type == 'weapon' then g.setColor(255, 150, 150, alpha)
      elseif p.slots[i].type == 'skill' then g.setColor(150, 150, 255, alpha)
      else g.setColor(255, 255, 255, alpha) end
      g.printCenter(str, iconx, top + (width * s) + 2, true, false)
    end
  end
end
