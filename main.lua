require 'lib/love'
require 'lib/util'
require 'lib/slam'
setmetatable(_G, {
  __index = require('lib/cargo').init('/')
})

require 'require'

app.core.context:bind(app.patcher)

