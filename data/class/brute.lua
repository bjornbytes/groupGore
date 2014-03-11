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
Brute.anchorx = 16
Brute.anchory = 22
Brute.handx = 26
Brute.handy = 5
Brute.sprite = 'media/graphics/brute.png'


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