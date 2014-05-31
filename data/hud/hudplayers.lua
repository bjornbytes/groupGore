HudPlayers = class()

local g = love.graphics
local w, h = g.width, g.height

function HudPlayers:draw()
  g.setFont('aeromatics', h(.02))
  ctx.players:each(function(p)
    local vx, vy = math.lerp(ctx.view.prevx, ctx.view.x, tickDelta / tickRate), math.lerp(ctx.view.prevy, ctx.view.y, tickDelta / tickRate)
    local px, py = p:drawPosition()
    local alpha = p.alpha * (1 - (p.cloak / (p.team == ctx.players:get(ctx.id).team and 2 or 1)))
    g.setColor(0, 0, 0, 100 * alpha)
    g.printCenter(p.username, (px - vx) * ctx.view.scale + 1, ((py - vy) * ctx.view.scale) - 60 + 1)
    if p.team == purple then g.setColor(190, 160, 220, alpha * 255)
    elseif p.team == orange then g.setColor(240, 160, 140, alpha * 255) end
    g.printCenter(p.username, (px - vx) * ctx.view.scale, ((py - vy) * ctx.view.scale) - 60)

    if not p.ded then
      local x0 = ((px - vx) * ctx.view.scale) - 40
      local y0 = ((py - vy) * ctx.view.scale) - 50
      local healthWidth, shieldWidth = (p.health / p.maxHealth) * 80, (p.shield / p.maxHealth) * 80
      local totalWidth = math.max(healthWidth + shieldWidth, 80)

      g.setColor(0, 0, 0, 128 * alpha) -- Dark background
      g.rectangle('fill', x0, y0, totalWidth, 10)
      
      g.setColor(200, 0, 0, 128 * alpha) -- Health
      g.rectangle('fill', x0 + .5, y0 + .5, healthWidth - 1, 10 - 1)
      
      g.setColor(220, 220, 220, 128 * alpha) -- Shield
      g.rectangle('fill', x0 + healthWidth, y0, shieldWidth, 10)
      
      g.setColor(150, 0, 0, 255 * alpha) -- Frame
      g.rectangle('line', x0, y0, totalWidth, 10)
    end
  end)
end