local json = require('spine-love/dkjson')

MenuHub = class()

function MenuHub:init()
  self.thread = love.thread.newThread('app/hub/hub.lua')
  self.thread:start()

  self.receiveQueue = love.thread.getChannel('hubReceiveQueue')
  self.sendQueue = love.thread.getChannel('hubSendQueue')
end

function MenuHub:update()
  while true do
    local message = self.receiveQueue:pop()
    if not message then break end
    
    message = json.decode(message)
    if message and message.cmd then
      ctx:hubMessage(message.cmd, message.payload)
    end
  end

  --[[if not ctx.offline and self.thread:getError() then
    print('problem with hub -- running in offline mode')
    print(self.thread:getError())
    ctx.offline = true

    ctx.user = {
      username = 'bjorn',
      units = {'bruju', 'thuju', 'kuju', 'buju'},
      deck = {
        { code = 'bruju',
          skin = {},
          runes = {}
        }
      },
      runes = {
        { token = 123,
          id = 1
        },
        { token = 345,
          id = 2
        }
      }
    }

    ctx:push('main')
  end]]
end

function MenuHub:send(cmd, payload)
  local data = {cmd = cmd, token = ctx.user and ctx.user.token or nil, payload = payload or setmetatable({}, {__jsontype = 'object'})}
  self.sendQueue:push(json.encode(data))
end
