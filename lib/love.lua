function love.run()
  if love.math then
    love.math.setRandomSeed(os.time())
  end

  tick = 0
  tickRate = .02
  tickDelta = 0
  syncRate = .05
  syncDelta = 0
  interp = .1

  love.load(arg)

  delta = 0

  while true do
    love.timer.step()
    delta = love.timer.getDelta()

    tickDelta = tickDelta + delta
    while tickDelta >= tickRate do
      tick = tick + 1
      tickDelta = tickDelta - tickRate
      
      love.event.pump()
      local releases = {}
      for e, a, b, c, d in love.event.poll() do
        if e == 'quit' then f.exe(love.quit) love.audio.stop() return
        else love.handlers[e](a, b, c, d) end
      end
      
      love.update()
    end

    syncDelta = syncDelta + delta
    if syncDelta >= syncRate then
      love.sync()
      syncDelta = 0
    end
    
    love.graphics.clear()
    love.draw()
    love.graphics.present()
    
    love.timer.sleep(.006)
  end
end

function love.graphics.rectangleCenter(style, x, y, w, h, pix)
  local ox, oy = math.round(x - (w / 2)), math.round(y - (h / 2))
  if pix then ox = ox + .5 oy = oy + .5 end
  love.graphics.rectangle(style, ox, oy, w, h)
end

function love.graphics.printCenter(str, x, y, h, v)
  local xx = x - ((h or (h == nil)) and (love.graphics.getFont():getWidth(str) / 2) or 0)
  local yy = y - ((v or (v == nil)) and (love.graphics.getFont():getHeight() / 2) or 0)
  love.graphics.print(str, xx, yy)
end