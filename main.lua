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
  data.load()
	Context:add(arg[2] == 'server' and Server or Menu)
end

love.update = Context.update
love.draw = Context.draw
love.quit = Context.quit

love.handlers = setmetatable({}, {__index = Context})
