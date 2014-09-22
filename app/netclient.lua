NetClient = extend(Net)

NetClient.signatures = {}
NetClient.signatures[msgJoin] = {important = true}
NetClient.signatures[msgLeave] = {important = true}
NetClient.signatures[msgInput] = {
  {'tick', '16bits'},
  {'x', 'float'}, {'y', 'float'},
  {'minion', '3bits'},
  delta = {{'x', 'y'}, 'minion'}
}

NetClient.receive = {}
NetClient.receive['default'] = function(self, event) ctx.event:emit(event.msg, event.data) end

NetClient.receive[msgJoin] = function(self, event)
  print(event.data.id)
  ctx.id = event.data.id
  ctx.tick = event.data.tick + math.floor(((event.peer:round_trip_time() / 2) / 1000) / tickRate)
  ctx.players:add(ctx.id)
end

function NetClient:init()
  self.other = NetServer
  self:connectTo('127.0.0.1', 6061)
  self.messageBuffer = {}

  ctx.event:on(evtSync, function(data)
    local p = ctx.players:get(data.id)
    if p and p.active then
      p:trace(data)
    end
  end)

  ctx.event:on('game.quit', function(data)
    self:quit()
  end)

  Net.init(self)
end

function NetClient:quit()
  self:send(msgLeave)
  if self.host then self.host:flush() end
  if self.server then self.server:disconnect() end
end

function NetClient:connect(event)
  self.server = event.peer
  self:send(msgJoin)
  event.peer:ping()
  print('connected')
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
