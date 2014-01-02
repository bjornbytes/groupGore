local Knife = {}

----------------
-- Meta
----------------
Knife.name = 'Knife'
Knife.code = 'knife'
Knife.icon = 'media/graphics/icon.png'
Knife.text = 'It is a knife.'
Knife.type = 'weapon'


----------------
-- Data
----------------
Knife.damage = 30
Knife.cooldown = .65


----------------
-- Behavior
----------------
Knife.activate = function(self, myKnife)
  myKnife.timer = 0
end

Knife.update = function(self, myKnife)
  myKnife.timer = timer.rot(myKnife.timer)
end

Knife.canFire = function(self, myKnife)
  return myKnife.timer == 0
end

Knife.fire = function(self, myKnife)
  ovw.spells:activate(self.id, data.spell.knife)
  myKnife.timer = myKnife.cooldown
end

return Knife
