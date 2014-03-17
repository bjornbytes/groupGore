HudDebug = class()

local g = love.graphics

function HudDebug:init()
  self.font = love.graphics.newFont('media/fonts/aeromatics.ttf', h() * .02)
end

function HudDebug:draw()
  g.setColor(255, 255, 255, 100)
  local debug = love.timer.getFPS() .. 'fps'
  if ovw.net.server then
    debug = debug .. ', ' .. ovw.net.server:round_trip_time() .. 'ms'
    debug = debug .. ', ' .. math.floor(ovw.net.host:total_sent_data() / 1000 + .5) .. 'tx'
    debug = debug .. ', ' .. math.floor(ovw.net.host:total_received_data() / 1000 + .5) .. 'rx'
  end
  g.print(debug, w() - self.font:getWidth(debug), h() - self.font:getHeight())
end