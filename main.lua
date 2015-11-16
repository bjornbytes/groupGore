require 'lib/util'
require 'lib/slam'
setmetatable(_G, {
  __index = require('lib/cargo').init('/')
})

require 'require'

Context:bind(Patcher)

