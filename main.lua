require 'require'

runes = {
  { name = 'Rune of Fortitude',
    description = 'Makes things stronker'
  }
}

testConfig = {
  ip = '127.0.0.1',
  port = 6061,
  players = {
    { username = 'bjorn',
      ip = '127.0.0.1',
      team = 1,
      color = 'purple',
      skin = {},
      deck = {
        { code = 'thuju',
          skin = {},
          runes = {}
        },
        { code = 'kuju',
          skin = {},
          runes = {}
        },
        { code = 'bruju',
          skin = {},
          runes = {}
        }
      }
    },
    --[[{ username = 'yoko',
      ip = '127.0.0.1',
      team = 2,
      color = 'purple',
      skin = {},
      deck = {
        { code = 'bruju',
          skin = {},
          runes = {}
        }
      }
    }]]
  },
  game = {
    gameType = 'versus',
    options = {}
  }
}

function love.load()
  data.load()

  if table.has(arg, 'server') then
    local config
    if table.has(arg, 'test') then
      config = testConfig
    else
      if love.filesystem.exists('config.json') then
        local json = require('spine-love/dkjson')
        local string = love.filesystem.read('config.json')
        config = json.decode(string)
      else
        error('Server missing config file')
      end
    end

    Context:add(Server, config)
  else
    Context:add(Menu)
  end
end

love.update = Context.update
love.draw = Context.draw
love.quit = Context.quit

love.handlers = setmetatable({}, {__index = Context})
