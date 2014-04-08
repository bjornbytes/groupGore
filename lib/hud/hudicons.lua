HudIcons = class()

local g = love.graphics
local w, h = g.width, g.height

function HudIcons:init()
  self.smallFont = g.newFont('media/fonts/aeromatics.ttf', h() * .018)
  self.font = g.newFont('media/fonts/aeromatics.ttf', h() * .025)
  self.prevLabelAlphas = {}
  self.labelAlphas = {}
  for i = 1, 5 do
    self.prevLabelAlphas[i] = 1
    self.labelAlphas[i] = 1
  end
end

function HudIcons:update()
  local p = ovw.players:get(myId)
  if p and p.active then
    for i = 1, 5 do
      self.prevLabelAlphas[i] = self.labelAlphas[i]
      if p.input.weapon ~= i and p.input.skill ~= i then
        self.labelAlphas[i] = math.max(self.labelAlphas[i] - tickRate, 0)
      end
    end
  end
end

function HudIcons:keypressed(key)  
  for i = 1, 5 do
    if key == tostring(i) then
      self.labelAlphas[i] = 2
    end
  end
end

function HudIcons:draw()
  local p = ovw.players:get(myId)
  if p and p.active then
    local width = p.slots[1].icon:getWidth()
    local s = g.minUnit(.08) / width
    for i = 1, 5 do
      local iconx = w(.5) - g.minUnit(.213) + g.minUnit(.106 * (i - 1))
      if p.input.weapon == i or p.input.skill == i then love.graphics.setColor(255, 255, 255, 255)
      else love.graphics.setColor(255, 255, 255, 128) end
      love.graphics.draw(p.slots[i].icon, iconx - (width / 2), h(.093), 0, s, s)

      local prc = 0      
      if p.slots[i].type == 'weapon' then
        prc = p.slots[i].timers.reload / p.slots[i].reload * 100
      elseif p.slots[i].value then
        prc = p.slots[i]:value() * 100
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
      
      g.setFontPixel('pixel', 8)
      local strw, strh = g.getFont():getWidth(p.slots[i].name), g.getFont():getHeight()
      local alpha = math.min(math.lerp(self.prevLabelAlphas[i], self.labelAlphas[i], tickDelta / tickRate), 1) * 200
      
      g.setColor(0, 0, 0, alpha)
      g.rectangle('fill', iconx - ((strw + 3) / 2), h(.093) + width + 1, strw + 3, strh + 2)
      
      g.setColor(255, 255, 255, alpha)
      g.printCenter(p.slots[i].name, iconx, h(.093) + width + 2, true, false)
    end
  end
end