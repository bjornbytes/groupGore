local Left = class()

local g = love.graphics

function Left:init()
  self.offset = -data.media.graphics.hud.left:getWidth() * ctx.view.scale
  self.prevOffset = self.offset
end

function Left:update()
  local p = ctx.players:get(ctx.id)
  if p then
    self.prevOffset = self.offset
    local first = f.exe(p.slots[p.weapon].ammoValue, p.slots[p.weapon], p)
    if first then
      self.offset = math.lerp(self.offset, -ctx.hud.u * .08, math.min(20 * tickRate, 1))
    else
      self.offset = math.lerp(self.offset, -data.media.graphics.hud.left:getWidth() * ctx.view.scale, math.min(20 * tickRate, 1))
    end
  end
end

function Left:draw()
  local u, v = ctx.hud.u, ctx.hud.v
  local s = ctx.view.scale
  local offset = math.lerp(self.prevOffset, self.offset, tickDelta / tickRate)

  local p = ctx.players:get(ctx.id)
  if p then
    local first, second = f.exe(p.slots[p.weapon].ammoValue, p.slots[p.weapon], p)

    g.setColor(255, 255, 255, 64)
    g.draw(data.media.graphics.hud.leftBg, offset + .0025, -v * .0083, 0, s, s)

    g.setColor(255, 255, 255)
    g.draw(data.media.graphics.hud.left, offset, -v * .013, 0, s, s)

    if first then
      local str = tostring(first)
      if second then str = str .. ' /' end

      g.setFont('BebasNeue', v * .065)
      local font = g:getFont()
      g.setColor(0, 0, 0, 100)
      g.printCenter(str, offset + u * .115 + 2, -v * .004 + 2, true, false)
      if p.team == purple then g.setColor(190, 160, 220)
      else g.setColor(240, 160, 140) end
      g.printCenter(str, offset + u * .115, -v * .004, true, false)

      if second then
        g.setFont('BebasNeue', v * .045)
        g.setColor(0, 0, 0, 100)
        g.printCenter(second, offset + u * .1175 + (font:getWidth(str) / 2) + (g.getFont():getWidth(second) / 2) + 2, v * .015 + 2, true, false)
        if p.team == purple then g.setColor(190, 160, 220)
        else g.setColor(240, 160, 140, 220) end
        g.printCenter(second, offset + u * .1175 + (font:getWidth(str) / 2) + (g.getFont():getWidth(second) / 2), v * .015, true, false)
      end
    end
  end
end

return Left
