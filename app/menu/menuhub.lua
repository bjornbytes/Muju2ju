local json = require 'lib/deps/dkjson'

MenuHub = class()

function MenuHub:init()
  self.thread = love.thread.newThread('app/thread/hub.lua')
  self.thread:start()

  self.receiveQueue = love.thread.getChannel('hub.receive')
  self.sendQueue = love.thread.getChannel('hub.send')
end

function MenuHub:update()
  while true do
    local message = self.receiveQueue:pop()
    if not message then break end
    
    message = json.decode(message)
    if message and type(message) == 'table' and message.cmd then
      ctx:hubMessage(message.cmd, message.payload)
    end
  end
end

function MenuHub:send(cmd, payload)
  local data = {cmd = cmd, token = ctx.user and ctx.user.token or nil, payload = payload or setmetatable({}, {__jsontype = 'object'})}
  self.sendQueue:push(json.encode(data))
end
