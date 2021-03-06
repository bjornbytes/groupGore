local Debug = class()

local g = love.graphics

function Debug:draw()
  if env ~= 'release' then
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
  end

  self.tStart = self.tStart or tick

  g.setColor(255, 255, 255, 100)
  local debug = love.timer.getFPS() .. 'fps'
  if ctx.net.server then
    debug = debug .. ', ' .. ctx.net.server:round_trip_time() .. 'ms'
    debug = debug .. ', ' .. math.round(ctx.net.host:total_sent_data() / 1000 / ((tick - self.tStart) * tickRate)) .. ' KB/s up'
    debug = debug .. ', ' .. math.round(ctx.net.host:total_received_data() / 1000 / ((tick - self.tStart) * tickRate)) .. ' KB/s dn'
  end
  g.setFont('aeromatics', ctx.hud.v * .02)
  g.print(debug, ctx.hud.u - g.getFont():getWidth(debug), ctx.hud.v - g.getFont():getHeight())
end

return Debug
