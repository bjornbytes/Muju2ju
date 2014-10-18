MenuHub = class()

MenuHub.handlers = {
  login = function(self, data)
    ctx.pages.login:loggedIn(data)
  end,

  saveDeck = function(self, data)
    -- 
  end
}

function MenuHub:init()
  self.receiveQueue = love.thread.getChannel('hubReceiveQueue')
  self.sendQueue = love.thread.getChannel('hubSendQueue')
end

function MenuHub:update()
  while true do
    local message = self.receiveQueue:pop()
    if not message then break end
    
    if message.cmd then
      f.exe(self.handlers[message.cmd], self, message)
    end
  end
end

function MenuHub:send(cmd, payload)
  payload.cmd = cmd
  self.sendQueue:push(payload)
end
