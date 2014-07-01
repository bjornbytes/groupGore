local Brute = {}
Brute.name = 'Brute'
Brute.code = 'brute'

----------------
-- Stats
----------------
Brute.health = 235
Brute.speed  = 165


----------------
-- Media
----------------
Brute.anchorx = 121
Brute.anchory = 172
Brute.handx = 241
Brute.handy = -40
Brute.sprite = data.media.graphics.brute
Brute.portrait = data.media.graphics.portraits.brute
Brute.scale = .2
Brute.quote = 'I AM BR00T'
Brute.offense = 6
Brute.defense = 7
Brute.utility = 2


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
