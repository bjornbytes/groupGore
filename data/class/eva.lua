local Eva = {}
Eva.name = 'Eva'
Eva.code = 'eva'

----------------
-- Stats
----------------
Eva.health = 180
Eva.speed  = 225


----------------
-- Media
----------------
Eva.anchorx = 91
Eva.anchory = 133
Eva.handx = 294
Eva.handy = 156
Eva.sprite = data.media.graphics.eva
Eva.scale = .2
Eva.quote = '???'


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
