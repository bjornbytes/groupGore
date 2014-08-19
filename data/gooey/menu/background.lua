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
  { kind = 'Label',
    properties = {
      x = .6,
      y = .05,
      text = 'group',
      color = {255, 255, 255},
      font = {'BebasNeue', .1},
    }
  }
}