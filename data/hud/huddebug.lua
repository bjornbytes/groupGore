HudDebug = class()

local g = love.graphics
local w, h = g.width, g.height

function HudDebug:draw()
  ctx.players:each(function(p)
    g.push()
    g.scale(ctx.view.scale)
    g.translate(-ctx.view.x, -ctx.view.y)
    if p.team == purple then g.setColor(190, 160, 220, p.alpha * 100)
    else g.setColor(240, 160, 140, p.alpha * 100) end
    p.shape:draw('fill')
    g.setLineWidth(2)
    if p.team == purple then g.setColor(190, 160, 220, p.alpha * 255)
    else g.setColor(240, 160, 140, p.alpha * 255) end
    p.shape:draw('line')
    g.setLineWidth(1)
    g.pop()
  end)

  g.setColor(255, 255, 255, 100)
  local debug = love.timer.getFPS() .. 'fps'
  if ctx.net.server then
    debug = debug .. ', ' .. ctx.net.server:round_trip_time() .. 'ms'
    debug = debug .. ', ' .. math.floor(ctx.net.host:total_sent_data() / 1000 + .5) .. 'tx'
    debug = debug .. ', ' .. math.floor(ctx.net.host:total_received_data() / 1000 + .5) .. 'rx'
  end
  g.setFont('aeromatics', h(.02))
  g.print(debug, w() - g.getFont():getWidth(debug), h() - ctx.view.margin * 2 - g.getFont():getHeight())
end
