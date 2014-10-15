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
          runes = {1, 1, nil, nil, nil, nil}
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

runes = {
  {
    id = 1,
    name = 'Fortitude Rune',
    description = 'Put it towards health.',
    tier = 1,
    values = {
      maxHealth = {10, 20, 30, 40, 50}
    }
  }
}

function love.load()
  data.load()
	Context:add(table.has(arg, 'server') and Server or Menu)
end

love.update = Context.update
love.draw = Context.draw
love.quit = Context.quit

love.handlers = setmetatable({}, {__index = Context})
