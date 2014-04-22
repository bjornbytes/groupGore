local SMG = extend(Weapon)

----------------
-- Meta
----------------
SMG.name = 'SMG'
SMG.code = 'smg'
SMG.text = 'It is a SMG.  It pumps people full of lead.'
SMG.type = 'weapon'


----------------
-- Data
----------------
SMG.image = 'media/graphics/smg.png'
SMG.damage = 14
SMG.fireSpeed = .15
SMG.reloadSpeed = 1.6
SMG.clip = 12
SMG.ammo = 120
SMG.spread = .03
SMG.recoil = 3
SMG.anchorx = 15
SMG.anchory = 7
SMG.tipx = 14
SMG.tipy = 0

return SMG
