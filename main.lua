require 'require'

function love.load()
  data.load()
	Context:add(arg[2] == 'server' and Server or Menu)
end

love.update = Context.update
love.draw = Context.draw
love.quit = Context.quit

love.handlers = setmetatable({}, {__index = Context})
