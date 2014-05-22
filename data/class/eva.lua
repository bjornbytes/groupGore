local Eva = {}
Eva.name = 'Eva'
Eva.code = 'eva'

----------------
-- Stats
----------------
Eva.health = 180
Eva.speed  = 195


----------------
-- Media
----------------
Eva.anchorx = 15
Eva.anchory = 17
Eva.handx = 22
Eva.handy = 0
Eva.sprite = data.media.graphics.eva
Eva.quote = '???'


----------------
-- Kit
----------------
Eva.slots = {}

Eva.slots[1] = data.weapon.knife
Eva.slots[2] = data.skill.shadowdash
Eva.slots[3] = data.skill.smokescreen
Eva.slots[4] = data.skill.shadowform
Eva.slots[5] = data.skill.backstab

return Eva
