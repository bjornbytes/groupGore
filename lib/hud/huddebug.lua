HudDebug = class()

local g = love.graphics
local w, h = g.width, g.height

function HudDebug:draw()
  g.setColor(255, 255, 255, 100)
  local debug = love.timer.getFPS() .. 'fps'
  if ovw.net.server then
    debug = debug .. ', ' .. ovw.net.server:round_trip_time() .. 'ms'
    debug = debug .. ', ' .. math.floor(ovw.net.host:total_sent_data() / 1000 + .5) .. 'tx'
    debug = debug .. ', ' .. math.floor(ovw.net.host:total_received_data() / 1000 + .5) .. 'rx'
  end
  g.setFont('aeromatics', 2)
  g.print(debug, w() - g.getFont():getWidth(debug), h() - ovw.view.margin * 2 - g.getFont():getHeight())
end