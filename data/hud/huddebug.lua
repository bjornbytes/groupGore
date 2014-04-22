HudDebug = class()

local g = love.graphics
local w, h = g.width, g.height

function HudDebug:draw()
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
