require './server/server'

Server:load()

tick = 0
tickRate = .02
tickDelta = 0
syncRate = .05
syncDelta = 0
interp = .1

local delta = 0
while true do  
  love.timer.step()
  delta = love.timer.getDelta()
  
  tickDelta = tickDelta + delta
  while tickDelta >= tickRate do
    love.event.pump()
      for e, a, b, c, d in love.event.poll() do
      if e == 'quit' then
        Server:quit()
        love.audio.stop()
        return
      end
      love.handlers[e](a, b, c, d)
    end
    
    tick = tick + 1
    tickDelta = tickDelta - tickRate
    Server:update()
  end
  
  syncDelta = syncDelta + delta
  if syncDelta >= syncRate then
    Server:sync()
    syncDelta = 0
  end
  
  love.graphics.clear()
  love.graphics.present()
  
  love.timer.sleep(.001)
end