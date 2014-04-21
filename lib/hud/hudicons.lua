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
  if p and p.active then
    for i = 1, 5 do
      self.prevLabelAlphas[i] = self.labelAlphas[i]
      if p.input.weapon == i or p.input.skill == i then
        self.labelAlphas[i] = math.lerp(self.labelAlphas[i], 1, 10 * tickRate)
      elseif p.slots[i].type == 'passive' then
        self.labelAlphas[i] = math.lerp(self.labelAlphas[i], .5, 10 * tickRate)
      else
        self.labelAlphas[i] = math.lerp(self.labelAlphas[i], .5, 10 * tickRate)
      end
    end
  end
end

function HudIcons:draw()
  local p = ctx.players:get(ctx.id)
  if p and p.active then
    local width = p.slots[1].icon:getWidth()
    local s = g.minUnit(.08) / width
    for i = 1, 5 do
      local alpha = math.min(math.lerp(self.prevLabelAlphas[i], self.labelAlphas[i], tickDelta / tickRate), 1) * 200
      local iconx = w(.5) - g.minUnit(.213) + g.minUnit(.106 * (i - 1))
      g.setColor(255, 255, 255, math.max(alpha, 100) * (255 / 200))
      g.draw(p.slots[i].icon, iconx - (width / 2), h(.093), 0, s, s)

      local prc = 0      
      if p.slots[i].value then
        prc = p.slots[i].value(p, p.slots[i]) * 100
      end

      g.setColor(0, 0, 0, 128)
      local x, y = iconx, h(.093)
      
      local points = {}
      local function insert(x, y)
        table.insert(points, x)
        table.insert(points, y + 1)
      end
      
      insert(x, y + h(.036))
      insert(x, y)
      
      local function halp(val, xx, yy)
        if prc > val then
          x = x + w(xx / 800)
          y = y + w(yy / 800)
          prc = prc - val
          insert(x, y)
          return false
        else
          x = x + ((prc / val) * w(xx / 800))
          y = y + ((prc / val) * w(yy / 800))
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
      g.rectangle('fill', iconx - ((strw + 3) / 2), h(.093) + width + 1, strw + 3, strh + 2)
      
      if p.slots[i].type == 'weapon' then g.setColor(255, 150, 150, alpha)
      elseif p.slots[i].type == 'skill' then g.setColor(150, 150, 255, alpha)
      else g.setColor(255, 255, 255, alpha) end
      g.printCenter(str, iconx, h(.093) + width + 2, true, false)
    end
  end
end
