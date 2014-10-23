require 'require'

function love.load()
  data.load()

  if table.has(arg, 'server') then
    if love.filesystem.exists('config.json') then
      local json = require('spine-love/dkjson')
      local string = love.filesystem.read('config.json')
      Context:add(Server, json.decode(config))
    else
      error('Server missing config file')
    end
  else
    Context:add(Menu)
  end
end

love.update = Context.update
love.draw = Context.draw
love.quit = Context.quit

love.handlers = setmetatable({}, {__index = Context})
