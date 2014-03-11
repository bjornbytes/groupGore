local Assassin = {}
Assassin.name = 'Assassin'
Assassin.code = 'assassin'

----------------
-- Stats
----------------
Assassin.health = 160
Assassin.speed  = 195
Assassin.size = 18


----------------
-- Media
----------------
Assassin.anchorx = 15
Assassin.anchory = 17
Assassin.handx = 22
Assassin.handy = 0
Assassin.sprite = 'media/graphics/assassin.png'


----------------
-- Kit
----------------
Assassin.slots = {}

Assassin.slots[1] = data.weapon.knife
Assassin.slots[2] = data.skill.roll
Assassin.slots[3] = data.skill.backstab
Assassin.slots[4] = data.skill.nimble
Assassin.slots[5] = data.skill.shadowform

return Assassin