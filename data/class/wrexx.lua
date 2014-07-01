local Wrexx = {}
Wrexx.name = 'Wrexx'
Wrexx.code = 'wrexx'

----------------
-- Stats
----------------
Wrexx.health = 260
Wrexx.speed  = 150


----------------
-- Media
----------------
Wrexx.anchorx = 121
Wrexx.anchory = 172
Wrexx.handx = 241
Wrexx.handy = -40
Wrexx.sprite = data.media.graphics.brute
Wrexx.portrait = data.media.graphics.portraits.brute
Wrexx.scale = .22
Wrexx.quote = 'I\'m gonna Wreck \'em!'
Wrexx.offense = 3
Wrexx.defense = 7
Wrexx.utility = 5


----------------
-- Kit
----------------
Wrexx.slots = {}

Wrexx.slots[1] = data.weapon.battleaxe
Wrexx.slots[2] = data.skill.rocketboots
Wrexx.slots[3] = data.skill.cleave
Wrexx.slots[4] = data.skill.overexertion
Wrexx.slots[5] = data.skill.tenacity

return Wrexx
