if arg[2] ~= 'test' then return end

for _, file in ipairs(love.filesystem.getDirectoryItems('test')) do
  if file ~= 'runner.lua' and file ~= 'lust.lua' then
    love.filesystem.load('test/' .. file)()
  end
end

love.graphics.setBackgroundColor(35, 35, 35)
love.graphics.clear()
love.graphics.setFont('pixel', 8)
local font = love.graphics:getFont()
love.graphics.setColor(0, 192, 0)
love.graphics.printf('all clear', 64, 64 + font:getHeight() * 4, love.graphics.getWidth() - 64)
love.graphics.present()

local t = 0
love.timer.step()
while t < 3 do
  love.timer.step()
  t = t + love.timer.getDelta()

  love.event.pump()

  for e, a, b, c in love.event.poll() do
    if e == 'quit' then t = 3 end
    if e == 'keypressed' and a == 'escape' then t = 3 end
  end
end

love.event.quit()
love.load = f.empty
