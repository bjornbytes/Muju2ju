require 'require'

config = {
  ip = '127.0.0.1',
  port = 6061,
  players = {
    {
      username = 'trey',
      ip = '127.0.0.1',
      team = 1,
      color = 'purple',
      skin = {},
      deck = {
        {
          code = 'bruju',
          skin = {},
          runes = {
            {1, 2, nil},
            {nil, nil},
            {nil}
          }
        }
      }
    }
  },
  game = {
    kind = 'survival',
    options = {
      difficulty = 'hard'
    }
  }
}

function love.load()
  if love.filesystem.exists('config.json') then
    local json = require('spine-love/dkjson')
    local string = love.filesystem.read('config.json')
    config = require('spine-love/dkjson').decode(string)
  end

  data.load()
	Context:add(arg[2] == 'server' and Server or Menu)
end

love.update = Context.update
love.draw = Context.draw
love.quit = Context.quit

love.handlers = setmetatable({}, {__index = Context})
