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
  { name = 'panel',
    kind = 'Element',
    properties = {
      y = 0,
      width = 1,
      height = .5,
      background = {0, 0, 0, 80}
    },
    children = {
      --[[{ kind = 'RichText',
        properties = {
          x = 0,
          y = 0,
          height = .5,
          padding = 16,
          font = 'coolvetica',
          richtext = {'{purple}g{orange}G', 800, purple = {190, 160, 220}, orange = {240, 160, 140}}
        }
      },]]
      { kind = 'TextField',
        properties = {
          x = .3,
          y = .2,
          width = .4,
          height = .1,
          padding = 8,
          font = 'aeromatics',
          text = 'Username',
          placeholder = 'xXanimegurl77Xx',
          border = {255, 255, 255}
        }
      }
    }
  }
}
