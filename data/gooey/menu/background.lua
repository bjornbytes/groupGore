return {
  code = 'background',
  { name = 'background',
    kind = 'Element',
    properties = {
      width = 1,
      height = 1,
      background = data.media.graphics.menu.ggbg
    }
  },
  { kind = 'Element',
    properties = {
      y = .2,
      width = 1,
      height = .1,
      background = {0, 0, 0, 80}
    }
  },
  { kind = 'RichText',
    properties = {
      x = .6,
      y = .04,
      font = {'BebasNeue', .1},
      richtext = {'{dark}group{light}Gore', nil, dark = {50, 50, 50}, light = {160, 160, 160}}
    }
  }
}