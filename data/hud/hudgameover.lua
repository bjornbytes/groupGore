HudGameOver = class()

function HudGameOver:init()
  self.alpha = 0
end

function HudGameOver:update()
  if ctx.map.winner then
    self.alpha = math.lerp(self.alpha, 1, math.min(5 * tickRate, 1))
  else
    self.alpha = 0
  end
end

function HudGameOver:draw()
  if not ctx.map.winner then return end
  local u, v = ctx.hud.u, ctx.hud.v
  local p = ctx.players:get(ctx.id)
  local g = love.graphics

  local str = p.team == ctx.map.winner and 'Victory!' or 'Defeat!'
  g.setFont('BebasNeue', v * .1)
  g.setColor(0, 0, 0, 100)
  g.printCenter(str, u * .5 + 2, v * .5 + 2)
  g.setColor(p.team == ctx.map.winner and (p.team == purple and {190, 160, 200} or {240, 160, 140}) or {150, 0, 0})
  g.printCenter(str, u * .5, v * .5)
end