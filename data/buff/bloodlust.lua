local Bloodlust = {}

----------------
-- Meta
----------------
Bloodlust.name = 'Bloodlust'
Bloodlust.code = 'bloodlust'
Bloodlust.text = 'This Brute is gaining health because he killed someone.'
Bloodlust.icon = 'media/graphics/icon.png'
Bloodlust.hide = false


----------------
-- Data
----------------
Bloodlust.healRate = 25


----------------
-- Behavior
----------------
Bloodlust.activate = function(self, myBloodlust)
	myBloodlust.hp = 5
end

Bloodlust.update = function(self, myBloodlust)
	myBloodlust.hp = timer.rot(myBloodlust.hp, function() Buff:remove(self, data.buff.bloodlust) end)
	self.health = math.min(self.health + (Bloodlust.healRate * tickRate), self.maxHealth)
end

return Bloodlust