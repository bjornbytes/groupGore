HudGameOver = class()

function HudGameOver:init()
  self.alpha = 0
end

function HudGameOver:update()
  if ctx.map.winner then
    self.alpha = math.lerp(self.alpha, 1, math.min(10 * tickRate, 1))
  else
    self.alpha = 0
  end
end

function HudGameOver:draw()
  if not ctx.map.winner then return end
  local u, v = ctx.hud.u, ctx.hud.v
  local p = ctx.players:get(ctx.id)
  local g = love.graphics
  
  g.setColor(ctx.map.winner == purple and {190 / 4, 160 / 4, 200 / 4, 150} or {240 / 4, 160 / 4, 140 / 4, 150})
  g.rectangleCenter('fill', u * .5, v * .5, u * .3, v * .3)
  g.setColor(ctx.map.winner == purple and {190, 160, 200} or {240, 160, 140})
  g.rectangleCenter('line', u * .5, v * .5, u * .3, v * .3)

  local str = p.team == ctx.map.winner and 'Victory!' or 'Defeat!'
  g.setFont('BebasNeue', v * .06)
  g.setColor(0, 0, 0, 100)
  g.printCenter(str, u * .5 + 2, v * .5 + 2)
  g.setColor(255, 255, 255)
  g.printCenter(str, u * .5, v * .5)

  g.setFont('pixel', 8)
  g.setColor(ctx.map.winner == purple and {190, 160, 200} or {240, 160, 140})
  local names = ctx.hud.scoreboard.names[ctx.map.winner]
  local mvp = names:sub(1, names:find('\n'))
  if #mvp > 0 then
    g.printCenter('MVP:\n' .. mvp, u * .5, v * .5 + (v * .15) / 2)
  end
end