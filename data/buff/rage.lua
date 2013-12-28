local Rage = {}

----------------
-- Meta
----------------
Rage.name = 'Rage'
Rage.code = 'rage'
Rage.text = 'The brute is shielded from damage and gains lifesteal.'
Rage.icon = 'media/graphics/icon.png'
Rage.hide = false


----------------
-- Data
----------------
Rage.effects = {}
Rage.effects.shield = {
  health = 80,
  callback = function(self)
    ovw.buffs:remove(self.id, data.buff.rage)
  end
}
Rage.effects.lifesteal = .2

return Rage