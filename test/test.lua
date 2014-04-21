local lust = require 'test/lust'

lust.describe('groupGore', function()
  
  lust.describe('Basic server connectivity', function()
    -- Initial load
    data.load()
    serverIp = '127.0.0.1'
    serverPort = 6061
    username = 'testbot'
    
    -- Create server
    server = Context:add(Server)
    
    lust.describe('Single connect/disconnect', function()
      game = Context:add(Game)
      
      -- Wait for client to connect
      lust.waitUntil(function() return game.id ~= nil end, 25)
      
      lust.it('should assign client id', function()
        lust.expect(game.id).to.be(1)
      end)
      
      -- Initiate disconnect
      game.net:send(msgLeave)
      game.net.host:flush()
      Context:remove(game)
      game = nil
      
      -- Wait for server to recognize disconnect
      lust.waitUntil(function() return table.count(server.net.peerToPlayer) == 0 end, 25)
      
      lust.it('should clear server state on disconnect', function()
        lust.with(server, function()
          lust.expect(table.count(ctx.net.peerToPlayer)).to.be(0)
          lust.expect(ctx.net.peerToPlayer[1]).to.be(nil)
          lust.expect(ctx.net:nextPlayerId()).to.be(1)
        end)
      end)
    end)
    
    lust.describe('Multiple connections', function()
      local games = {}
      
      -- Create 10 clients
      for i = 1, 10 do
        games[i] = Context:add(Game)
      end
      
      -- Wait until they're all connected
      lust.waitUntil(function()
        for i = 1, 10 do
          if not games[i].id then return false end
        end
        return true
      end, 25)
      
      -- Disconnect them in a random order.
      while #games > 0 do
        local i = math.ceil(love.math.random() * #games)
        local game = games[i]
        game.net:send(msgLeave)
        game.net.host:flush()
        Context:remove(game)
        table.remove(games, i)
        lust.wait(love.math.random(10))
      end
      
      lust.it('should clear server state on disconnect', function()
        lust.with(server, function()
          lust.expect(server.net:nextPlayerId()).to.be(1)
          lust.expect(table.count(server.net.peerToPlayer)).to.be(0)
        end)
      end)
    end)
    
    lust.describe('Lots of joins', function()
      local game
      
      lust.it('Should handle rapid connects/disconnects', function()
        for _ = 1, 20 do
          game = Context:add(Game)
          lust.waitUntil(function() return game.id ~= nil end, 50)
          lust.expect(game.id).to.be(1)
          game.net:send(msgLeave)
          game.net.host:flush()
          Context:remove(game)
          game = nil
        end
      end)
    end)
  end)
end)
