HudRight = class()

local g = love.graphics

function HudRight:draw()
  local u, v = ctx.hud.u, ctx.hud.v
  local s = ctx.view.scale

  g.setColor(255, 255, 255, 64)
  g.draw(data.media.graphics.hud.rightBg, u * .81375, -v * .003, 0, s, s)
  
  g.setColor(255, 255, 255, 255)
  g.draw(data.media.graphics.hud.right, u * .80375, -v * .01, 0, s, s)
  
  local p = ctx.players:get(ctx.id)
  if p then
    g.setFont('BebasNeue', v * .052)
    g.setColor(0, 0, 0, 100)

    local scoring = ctx.map.mods.scoring
    if scoring and scoring.points then
      g.print(tostring(scoring.points[p.team]), u * .85 + 2, -v * .008 + 2)
      if p.team == purple then g.setColor(190, 160, 220)
      else g.setColor(240, 160, 140) end
      g.print(tostring(scoring.points[p.team]), u * .85, -v * .008)
      
      local str = tostring(scoring.points[1 - p.team])
      local x = u * (.80375 + (data.media.graphics.hud.right:getWidth() * s / u) - .0525) - g.getFont():getWidth(str)
      g.setColor(0, 0, 0, 100)
      g.print(str, x + 2, -v * .008 + 2)
      if p.team == purple then g.setColor(240, 160, 140)
      else g.setColor(190, 160, 220) end
      g.print(str, x, -v * .008)
    end
    --[[elseif ctx.map.rules.timer then
      g.printCenter(math.ceil(ctx.map.rules.timer), u * .80375 + (data.media.graphics.hud.right:getWidth() * s / 2) + 2, -v * .008 + 2, true, false)
      g.setColor(255, 255, 255)
      g.printCenter(math.ceil(ctx.map.rules.timer), u * .80375 + (data.media.graphics.hud.right:getWidth() * s / 2), -v * .008, true, false)
    end]]
  end
end
