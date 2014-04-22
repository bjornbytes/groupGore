local Shotgun = extend(Weapon)

----------------
-- Meta
----------------
Shotgun.name = 'Shotgun'
Shotgun.code = 'shotgun'
Shotgun.text = 'It is a shotgun.  It blows people to bits.'
Shotgun.type = 'weapon'


----------------
-- Data
----------------
Shotgun.image = 'media/graphics/shotgun.png'
Shotgun.damage = 25
Shotgun.fireSpeed = .65
Shotgun.reloadSpeed = 2
Shotgun.clip = 4
Shotgun.ammo = 16
Shotgun.spread = .06
Shotgun.recoil = 6
Shotgun.count = 4
Shotgun.anchorx = 14
Shotgun.anchory = 4
Shotgun.tipx = 29
Shotgun.tipy = 0

return Shotgun
