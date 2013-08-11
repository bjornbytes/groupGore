local Brute = {}
Brute.name = 'Brute'
Brute.code = 'brute'

----------------
-- Stats
----------------
Brute.health = 235
Brute.speed  = 150
Brute.size = 20


----------------
-- Media
----------------
Brute.anchor = {}
Brute.anchor.x = 55
Brute.anchor.y = 35

Brute.sprites = {}
Brute.sprites.head = 'media/graphics/bruteHead.png'
Brute.sprites.body = 'media/graphics/bruteBody.png'


----------------
-- Kit
----------------
Brute.slots = {}

Brute.slots[1] = data.weapon.shotgun
Brute.slots[2] = data.weapon.smg
Brute.slots[3] = data.skill.adrenaline
Brute.slots[4] = data.skill.rage
Brute.slots[5] = data.skill.bloodlust

return Brute