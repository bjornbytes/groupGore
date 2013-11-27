local map = ({(...)})[1]

return {
  {
    x = 128,
    y = 128 + 128,
    w = 192,
    h = 64 
  },
  {
    x = 128 + 128,
    y = 128,
    w = 64,
    h = 128
  },
  {
    x = map.width - (128 + 128 + 64),
    y = map.height - (128 + 128),
    w = 64,
    h = 128
  },
  {
    x = map.width - (128 + 192),
    y = map.height - (128 + 128 + 64),
    w = 192,
    h = 64
  },
  {
    x = (map.width / 2) - 32,
    y = (map.height / 2) - 128,
    w = 64,
    h = 128
  },
  {
    x = (map.width / 2) - 128,
    y = (map.height / 2) - 32,
    w = 128,
    h = 64
  },
  {
    x = (map.width / 2) - 32,
    y = (map.height / 2),
    w = 64,
    h = 128
  },
  {
    x = (map.width / 2),
    y = (map.height / 2) - 32,
    w = 128,
    h = 64
  },
  {
    x = (map.width * .25) - 96,
    y = (map.height * .75) - 96,
    w = 192,
    h = 192
  },
  {
    x = (map.width * .75) - 96,
    y = (map.height * .25) - 96,
    w = 192,
    h = 192
  },
  {
    x = (map.width * .5) - 128,
    y =  256,
    w = 256,
    h = 64
  },
  {
    x = (map.width * .5) - 128,
    y = map.height - (256 + 64),
    w = 256,
    h = 64
  }
}