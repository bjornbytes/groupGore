local Overexertion = {}

Overexertion.name = 'Overexertion'
Overexertion.code = 'overexertion'
Overexertion.text = 'The Power'
Overexertion.type = 'skill'

Overexertion.cooldown = 8
Overexertion.cost = 40

function Overexertion:activate(owner)
  self.timer = 0
end

function Overexertion:update(owner)
  self.timer = timer.rot(self.timer)
end

function Overexertion:canFire(owner)
  return false
end

function Overexertion:fire()
  --
end

return Overexertion