local jungleCarnage = {}

----------------
-- Meta
----------------
jungleCarnage.name = 'Jungle Carnage'
jungleCarnage.width = 1600
jungleCarnage.height = 1200


----------------
-- Spawn Points
----------------
jungleCarnage.spawn = {}

jungleCarnage.spawn[purple] = {
    x = 128,
    y = 128
}

jungleCarnage.spawn[orange] = {
    x = jungleCarnage.width - 128,
    y = jungleCarnage.height - 128
}


----------------
-- Props
----------------
jungleCarnage.props = {
  {
    kind = 'wall',
    x = 128,
    y = 128 + 128,
    w = 192,
    h = 64 
  },
  {
    kind = 'wall',
    x = 128 + 128,
    y = 128,
    w = 64,
    h = 128
  },
  {
    kind = 'wall',
    x = jungleCarnage.width - (128 + 128 + 64),
    y = jungleCarnage.height - (128 + 128),
    w = 64,
    h = 128
  },
  {
    kind = 'wall',
    x = jungleCarnage.width - (128 + 192),
    y = jungleCarnage.height - (128 + 128 + 64),
    w = 192,
    h = 64
  },
  {
    kind = 'wall',
    x = (jungleCarnage.width / 2) - 32,
    y = (jungleCarnage.height / 2) - 128,
    w = 64,
    h = 128
  },
  {
    kind = 'wall',
    x = (jungleCarnage.width / 2) - 128,
    y = (jungleCarnage.height / 2) - 32,
    w = 128,
    h = 64
  },
  {
    kind = 'wall',
    x = (jungleCarnage.width / 2) - 32,
    y = (jungleCarnage.height / 2),
    w = 64,
    h = 128
  },
  {
    kind = 'wall',
    x = (jungleCarnage.width / 2),
    y = (jungleCarnage.height / 2) - 32,
    w = 128,
    h = 64
  },
  {
    kind = 'wall',
    x = (jungleCarnage.width * .25) - 96,
    y = (jungleCarnage.height * .75) - 96,
    w = 192,
    h = 192
  },
  {
    kind = 'wall',
    x = (jungleCarnage.width * .75) - 96,
    y = (jungleCarnage.height * .25) - 96,
    w = 192,
    h = 192
  },
  {
    kind = 'wall',
    x = (jungleCarnage.width * .5) - 128,
    y =  256,
    w = 256,
    h = 64
  },
  {
    kind = 'wall',
    x = (jungleCarnage.width * .5) - 128,
    y = jungleCarnage.height - (256 + 64),
    w = 256,
    h = 64
  },
  {
    kind = 'tree',
    x = 350,
    y = 350
  }
}

return jungleCarnage