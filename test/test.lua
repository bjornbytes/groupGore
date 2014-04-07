require 'test/expect'

local lust = require 'test/lust'

describe('the menu', function()
  it('should work', function()
    love.load = function()
      data.load()
      gorgeous = Overwatch:add(Gorgeous)
      if not gorgeous.socket then gorgeous = nil end
      
      serverIp = '127.0.0.1'
      serverPort = 6061
      
      Overwatch:add(Server)
      game1 = Overwatch:add(Game)
    end
        
    lust.wait(10) -- Wait for everyone to handshake

    lust.next(function()
      expect(myId).to.be(1) -- Make sure we're player 1
      lust.trigger('keypressed', '1') -- Choose first class (Brute)
    end)
    
    lust.wait(3)
    
    lust.next(function()
      print(game1.players:get(myId).active)
      expect(game1.players:get(myId).class).to.equal(data.class.brute)
    end)
    
    lust.wait(25)

    lust.run()
  end)
end)