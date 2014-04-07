local Snow = {}
Snow.name = 'Snow'
Snow.code = 'snow'

function Snow:init()
  self.x = 0
  self.y = 0
  self.vx = 400 * (love.math.random() < .5 and -1 or 1)
  self.vy = 400 * (love.math.random() < .5 and -1 or 1)
  self.dx = love.math.random() < .5 and -1 or 1
  self.dy = love.math.random() < .5 and -1 or 1
  self.image = love.graphics.newImage('media/graphics/bgBlizzard.png')
  self.image:setWrap('repeat', 'repeat')
  self.depth = -10000
end

function Snow:update()
  --[[global.blizzardX+=global.blizzardHSpeed*(global.delta/global.timerResolution)
  global.blizzardY+=global.blizzardVSpeed*(global.delta/global.timerResolution)
  global.blizzardHSpeed+=global.blizzardHDSpeed*random_range(50,100)*(global.delta/global.timerResolution)
  global.blizzardVSpeed+=global.blizzardVDSpeed*random_range(50,100)*(global.delta/global.timerResolution)
  if global.blizzardHSpeed>300{global.blizzardHDSpeed=-1}
  else if global.blizzardHSpeed<-300{global.blizzardHDSpeed=1}
  if global.blizzardVSpeed>300{global.blizzardVDSpeed=-1}
  else if global.blizzardVSpeed<-300{global.blizzardVDSpeed=1}]]
    
  self.x = self.x + self.vx * tickRate
  self.y = self.y + self.vy * tickRate
  self.vx = self.vx + self.dx * love.math.random(50, 100) * tickRate
  self.vy = self.vy + self.dy * love.math.random(50, 100) * tickRate
  if self.vx > 300 then self.dx = -1
  elseif self.vx < -300 then self.dx = 1 end
  if self.vy > 300 then self.dy = -1
  elseif self.vy < -300 then self.dy = 1 end
end

function Snow:gui()
  --[[w3d_draw_background_tiled(bgBlizzard,global.blizzardX,global.blizzardY,64,1,1,c_white,.35)
  w3d_draw_background_tiled(bgBlizzard,global.blizzardX*1.1,global.blizzardY*1.1,128,1,1,c_white,.35)
  w3d_draw_background_tiled(bgBlizzard,global.blizzardX*1.2,global.blizzardY*1.2,256,1,1,c_white,.35)]]

  love.graphics.setColor(255, 255, 255, 90)
  local factor = 1
  local x, y = (ovw.view.x + ovw.view.w / 2 - self.x), (ovw.view.y + ovw.view.h / 2 - self.y)
  
  for _, z in ipairs({64, 128, 256}) do
    local scale = 1 + (ovw.view:convertZ(z) / 500)
    local quad = love.graphics.newQuad(x, y, love.graphics.getWidth(), love.graphics.getHeight(), self.image:getWidth(), self.image:getHeight())

    love.graphics.draw(self.image, quad, 0, 0, 0, scale, scale)
    factor = factor + .1
  end
end

return Snow