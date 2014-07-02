HudLeft = class()

local g = love.graphics

function HudLeft:draw()
  local u, v = ctx.hud.u, ctx.hud.v
  local s = ctx.view.scale

  g.setColor(255, 255, 255, 64)
  g.draw(data.media.graphics.hud.leftBg, -u * .0825, -v * .0083, 0, s, s)
  
  g.setColor(255, 255, 255)
  g.draw(data.media.graphics.hud.left, -u * .08, -v * .013, 0, s, s)
  
  local p = ctx.players:get(ctx.id)
  if p then
    local clip = tostring(p.slots[p.weapon].currentClip)
    local ammo = tostring(p.slots[p.weapon].currentAmmo)

    if clip ~= 'nil' and ammo ~= 'nil' then
      g.setFont('BebasNeue', v * .065)
      local font = g:getFont()
      g.setColor(0, 0, 0, 100)
      g.printCenter(clip .. ' /', u * .035 + 2, -v * .004 + 2, true, false)
      if p.team == purple then g.setColor(190, 160, 220)
      else g.setColor(240, 160, 140) end
      g.printCenter(clip .. ' /', u * .035, -v * .004, true, false)
      
      g.setFont('BebasNeue', v * .045)
      g.setColor(0, 0, 0, 100)
      g.printCenter(ammo, u * .0375 + (font:getWidth(clip .. ' /') / 2) + (g.getFont():getWidth(ammo) / 2) + 2, v * .015 + 2, true, false)
      if p.team == purple then g.setColor(190, 160, 220)
      else g.setColor(240, 160, 140, 220) end
      g.printCenter(ammo, u * .0375 + (font:getWidth(clip .. ' /') / 2) + (g.getFont():getWidth(ammo) / 2), v * .015, true, false)
    end
  end
end
