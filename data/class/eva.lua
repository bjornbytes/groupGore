local Eva = {}
Eva.name = 'Eva'
Eva.code = 'eva'

----------------
-- Stats
----------------
Eva.health = 180
Eva.speed  = 245


----------------
-- Media
----------------
Eva.anchorx = 91
Eva.anchory = 133
Eva.handx = 294
Eva.handy = 156
Eva.sprite = data.media.graphics.eva
Eva.portrait = data.media.graphics.portraits.eva
Eva.scale = .22
Eva.quote = '???'
Eva.offense = 8
Eva.defense = 1
Eva.utility = 6


----------------
-- Kit
----------------
Eva.slots = {}

Eva.slots[1] = data.weapon.dagger
Eva.slots[2] = data.skill.dusk
Eva.slots[3] = data.skill.smokescreen
Eva.slots[4] = data.skill.subterfuge
Eva.slots[5] = data.skill.backstab

return Eva
