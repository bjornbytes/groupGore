require 'enet'
require 'lib/love'
require 'lib/util'
require 'lib/slam'
require 'lib/typo'
setmetatable(_G, {
  __index = require('lib/cargo').init('/')
})

app.util.context:bind(app.context.patcher)
