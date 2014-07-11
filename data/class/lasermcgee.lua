local LaserMcGee = {}
LaserMcGee.name = 'Laser McGee'
LaserMcGee.code = 'lasermcgee'

LaserMcGee.locked = env == 'release'


----------------
-- Stats
----------------
LaserMcGee.health = 210
LaserMcGee.speed  = 180


----------------
-- Media
----------------
LaserMcGee.anchorx = 15
LaserMcGee.anchory = 20
LaserMcGee.handx = 30
LaserMcGee.handy = 0
LaserMcGee.sprite = data.media.graphics.lasermcgee
LaserMcGee.portrait = data.media.graphics.portraits.lasermcgee
LaserMcGee.scale = 1.4
LaserMcGee.quote = 'Ima firin\' Malaysia.'
LaserMcGee.offense = 7
LaserMcGee.defense = 2
LaserMcGee.utility = 6


----------------
-- Kit
----------------
LaserMcGee.slots = {}

LaserMcGee.slots[1] = data.weapon.energyrifle
LaserMcGee.slots[2] = data.weapon.plasmacannon
LaserMcGee.slots[3] = data.skill.staticgrenade
LaserMcGee.slots[4] = data.skill.lazor
LaserMcGee.slots[5] = data.skill.plasmasickness

return LaserMcGee
