local Brute = {}
Brute.name = 'Brute'

----------------
-- Stats
----------------
Brute.health = 235
Brute.speed  = 150


----------------
-- Media
----------------
Brute.sprite = 'media/graphics/brute.png'


----------------
-- Kit
----------------
Brute.slots = {}

Brute.slots[1] = 'data/brute/shotgun.lua'
Brute.slots[2] = 'data/brute/smg.lua'
Brute.slots[3] = 'data/brute/adrenaline.lua'
Brute.slots[4] = 'data/brute/rage.lua'
Brute.slots[5] = 'data/brute/bloodlust.lua'

return Brute