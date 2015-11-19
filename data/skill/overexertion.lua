local Overexertion = {}

Overexertion.name = 'Overexertion'
Overexertion.code = 'overexertion'
Overexertion.text = 'The Power'
Overexertion.type = 'skill'

Overexertion.cost = 40

function Overexertion:canFire(owner)
  return owner.health > self.cost and not ctx.buffs:get(owner, 'overexertion')
end

function Overexertion:fire(owner)
  ctx.net:emit(app.core.net.events.damage, {id = owner.id, amount = self.cost, from = owner.id, tick = tick})
  ctx.buffs:add(owner, 'overexertion')
end

return Overexertion
