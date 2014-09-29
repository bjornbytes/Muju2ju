NetClient = extend(Net)

NetClient.signatures = {}
NetClient.signatures[msgJoin] = {important = true}
NetClient.signatures[msgLeave] = {important = true}
NetClient.signatures[msgInput] = {
  {'tick', '16bits'},
  {'x', 'float'}, {'y', 'float'},
  {'summon', 'bool'},
  {'minion', '3bits'},
  delta = {{'x', 'y'}, 'minion'}
}

NetClient.handlers = {
  [msgJoin] = function(self, event)
    print('my id is ' .. event.data.id)
    ctx.id = event.data.id
    ctx.players:add(ctx.id)
  end,

  [msgSyncMain] = function(self, event) ctx.players:get(ctx.id):trace(event.data) end,
  [msgSyncDummy] = function(self, event) ctx.players:get(event.data.id):trace(event.data) end,

  default = function(self, event) ctx.event:emit(event.msg, event.data) end
}

function NetClient:init()
  self.other = NetServer
  self.state = 'connecting'
  self:connectTo('127.0.0.1', 6061)
  self.messageBuffer = {}

  ctx.event:on('game.quit', f.cur(self.quit, self))

  ctx.event:on(evtReady, function(data)
    ctx.tick = data.tick
    self.state = 'playing'
    for i = 1, 2 do
      if i ~= ctx.id then
        ctx.players:add(i)
      end
    end
  end)

  Net.init(self)
end

function NetClient:quit()
  self:send(msgLeave)
  if self.host then self.host:flush() end
  if self.server then self.server:disconnect() end
end

function NetClient:connect(event)
  self.state = 'waiting'
  self.server = event.peer
  self:send(msgJoin)
  event.peer:ping()
end

function NetClient:disconnect(event)
  ctx.event:emit('game.quit')
end

function NetClient:send(msg, data)
  if not self.server then return end
  
  self.outStream:clear()
  self:pack(msg, data)

  local important = self.signatures[msg].important
  local channel = important and 0 or 1
  local reliability = important and 'reliable' or 'unreliable'
  self.server:send(tostring(self.outStream), channel, reliability)
end

NetClient.emit = f.empty
