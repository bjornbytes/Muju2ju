MenuHub = class()

MenuHub.handlers = {
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
      f.exe(self.handlers[message.cmd], self, message.payload)
    end
  end
end

function MenuHub:send(cmd, payload)
  self.sendQueue:push({cmd = cmd, payload = payload})
end
