require 'enet'
require 'lib/love'
require 'lib/util'
require 'lib/slam'
require 'lib/typo'
setmetatable(_G, {
  __index = require('lib/cargo').init('/')
})

app.core.context:bind(app.patcher)
