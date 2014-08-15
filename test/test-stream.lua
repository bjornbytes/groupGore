local lust = require 'test/lust'
require 'lib/core/stream'

local stream = Stream()

lust.before = function() stream:clear() end

lust.describe('stream', function()

  lust.describe('numbers', function()

    lust.test('single bit', function()
      stream:write(0, '1bit')
      stream:truncate()
      lust.expect(stream:read('1bit')).to.equal(0)
    end)

    lust.test('single bit', function()
      stream:write(1, '1bit')
      stream:truncate()
      lust.expect(stream:read('1bit')).to.equal(1)
    end)

    lust.test('multiple numbers', function()
      stream:write(8, '4bits')
      stream:write(3, '4bits')
      stream:truncate()
      lust.expect(stream:read('4bits')).to.equal(8)
      lust.expect(stream:read('4bits')).to.equal(3)
    end)

  end)

  lust.describe('packing', function()
    local sig = {{'a', '5bits'}, {'b', '7bits'}, {'c', 'string'},
                  {'d', 'bool'}, {'e', '1bit'}, {'f', '1bit'}}

    lust.test('simple', function()
      stream:pack({a = 5, b = 2, c = 'purple', d = false, e = 0, f = 1}, sig)
      stream:truncate()
      local data = stream:unpack(sig)
      lust.expect(data).to.be({a = 5, b = 2, c = 'purple', d = false, e = 0, f = 1})
    end)

    lust.test('multi', function()
      stream:pack({a = 0, b = 3, c = '', d = false, e = 1, f = 0}, sig)
      stream:pack({a = 5, b = 2, c = 'purple', d = false, e = 0, f = 1}, sig)
      stream:truncate()
      local data = stream:unpack(sig)
      lust.expect(data).to.be({a = 0, b = 3, c = '', d = false, e = 1, f = 0})
      data = stream:unpack(sig)
      lust.expect(data).to.be({a = 5, b = 2, c = 'purple', d = false, e = 0, f = 1})
    end)

  end)
end)