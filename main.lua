require 'enet'

require 'lib/util'
require 'lib/stream'

require 'lib/buff'
require 'lib/buffs'
require 'lib/collision'
require 'lib/event'
require 'lib/gooey'
require 'lib/gorgeous'
require 'lib/hud'
require 'lib/linkedlist'
require 'lib/map'
require 'lib/net'
require 'lib/netclient'
require 'lib/netserver'
require 'lib/particle'
require 'lib/player'
require 'lib/playerdummy'
require 'lib/playermain'
require 'lib/playerserver'
require 'lib/playerrobot'
require 'lib/players'
require 'lib/richtext'
require 'lib/spell'
require 'lib/spells'
require 'lib/view'

require 'ovw/game'
require 'ovw/menu'
require 'ovw/ovw'
require 'ovw/server'

require 'data/loader'

function love.load()
  data.load()

  Overwatch:add(Menu)
  gorgeous = Overwatch:add(Gorgeous)
  if not gorgeous.socket then gorgeous = nil end

  love.update = Overwatch.update
  love.draw = Overwatch.draw
  love.sync = Overwatch.sync
  love.quit = Overwatch.quit
  
  love.handlers = {}
  setmetatable(love.handlers, {__index = Overwatch})
end

function love.run()
  math.randomseed(os.time()) math.random()

  tick = 0
  tickRate = .02
  tickDelta = 0
  syncRate = .05
  syncDelta = 0
  interp = .1

  love.load(arg)

  local delta = 0

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
        elseif e == 'mousereleased' or e == 'keyreleased' then table.insert(releases, {e, a, b, c, d})
        else love.handlers[e](a, b, c, d) end
      end
      
      love.update()
      
      for _, e in pairs(releases) do
        love.handlers[e[1]](e[2], e[3], e[4], e[5])
      end
    end

    syncDelta = syncDelta + delta
    if syncDelta >= syncRate then
      love.sync()
      syncDelta = 0
    end
    
    love.graphics.clear()
    love.draw()
    love.graphics.present()
    
    love.timer.sleep(.0125)
  end
end
