HudIcons = class()

local g = love.graphics

function HudIcons:init()
  self.smallFont = g.newFont('media/fonts/aeromatics.ttf', h() * .018)
  self.font = g.newFont('media/fonts/aeromatics.ttf', h() * .025)
end

function HudIcons:draw()
  local p = ovw.players:get(myId)
  if p and p.active then
    local width = p.slots[1].icon:getWidth()
    local s = w(.06) / width
    for i = 1, 5 do
      if p.input.weapon == i or p.input.skill == i then love.graphics.setColor(255, 255, 255, 255)
      else love.graphics.setColor(255, 255, 255, 128) end
      love.graphics.draw(p.slots[i].icon, w(.5 - .16 + (.08 * (i - 1))), 0, 0, s, s, width / 2, 0)
    end
  end
end