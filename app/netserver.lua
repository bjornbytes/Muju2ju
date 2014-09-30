NetServer = extend(Net)

NetServer.signatures = {}
NetServer.signatures[evtReady] = {{'tick', '16bits'}, important = true}
NetServer.signatures[evtLeave] = {{'id', '4bits'}, {'reason', 'string'}, important = true}
NetServer.signatures[evtSummon] = {{'id', '4bits'}, {'index', '2bits'}, important = true}
NetServer.signatures[evtDeath] = {{'id', '4bits'}, important = true}
NetServer.signatures[evtSpawn] = {{'id', '4bits'}, important = true}
NetServer.signatures[evtUnitSpawn] = {{'id', '10bits'}, {'owner', '3bits'}, {'kind', 'string'}, {'x', 'float'}, {'y', 'float'}}
NetServer.signatures[evtUnitSync] = {{'tick', '16bits'},
  {'units', {
    {'id', '10bits'}, {'x', 'float'}, {'y', 'float'}, {'health', '10bits'}}
  }
}
NetServer.signatures[msgJoin] = {{'id', '4bits'}, important = true}
NetServer.signatures[msgSyncMain] = {
  {'ack', '16bits'},
  {'x', 'float'},
  {'juju', '12bits'},
  {'health', '8bits'},
  {'ghostX', 'float'},
  {'ghostY', 'float'},
  delta = {{'x', 'health'}, {'ghostX', 'ghostY'}}
}
NetServer.signatures[msgSyncDummy] = {
  {'id', '2bits'},
  {'tick', '16bits'},
  {'x', 'float'},
  {'health', '8bits'},
  {'animationIndex', '3bits'},
  {'animationPrev', '3bits'},
  {'animationTime', 'float'},
  {'animationPrevTime', 'float'},
  {'animationAlpha', 'float'},
  {'animationFlip', 'bool'},
  {'ghostX', 'float'},
  {'ghostY', 'float'},
  {'ghostAngle', '9bits'},
  delta = {{'x', 'health'}, {'ghostX', 'ghostY', 'ghostAngle'}}
}

NetServer.handlers = {
  [msgJoin] = function(self, event)
    local pid = self.peerToPlayer[event.peer]
    self:send(msgJoin, event.peer, {id = pid})
    ctx.players:add(pid)
    ctx.players:get(pid).peer = event.peer
    print('player ' .. pid .. ' connected')
    if table.count(ctx.players.players) == 2 then
      self:emit(evtReady, {tick = tick})
      self.state = 'playing'
    end
  end,

  [msgLeave] = function(self, event) self:disconnect(event) end,
  [msgInput] = function(self, event) ctx.players:get(self.peerToPlayer[event.peer]):trace(event.data) end,
  default = f.empty
}

function NetServer:init()
  self.other = NetClient
  self.state = 'waiting'

  self:listen(6061)
  self.peerToPlayer = {}
  self.eventBuffer = {}
  self.importantEventBuffer = {}

  ctx.event:on('game.quit', f.cur(self.quit, self))

  Net.init(self)
end

function NetServer:quit()
  if self.host then
    ctx.players:each(function(player)
      if self.host:get_peer(player.id) then self.host:get_peer(player.id):disconnect_now() end
    end)
    self.host:flush()
  end
  self.host = nil
end

function NetServer:connect(event)
  self.peerToPlayer[event.peer] = #ctx.players.players + 1
  event.peer:timeout(0, 0, 3000)
  event.peer:ping()
end

function NetServer:disconnect(event)
  local pid = self.peerToPlayer[event.peer]
  local reason = event.reason or 'left'
  self:emit(evtLeave, {id = pid, reason = reason})
  self.peerToPlayer[event.peer] = nil
  event.peer:disconnect_now()
end

function NetServer:send(msg, peer, data)
  self.outStream:clear()
  self:pack(msg, data)
  peer:send(tostring(self.outStream))
end

function NetServer:emit(evt, data)
  if not self.host then return end
  local buffer = self.signatures[evt].important and self.importantEventBuffer or self.eventBuffer
  table.insert(buffer, {evt, data, tick})
  ctx.event:emit(evt, data)
end

function NetServer:sync()
  if not self.host then return end
  
  if #self.importantEventBuffer > 0 then
    self.outStream:clear()
    while #self.importantEventBuffer > 0 and (tick - self.importantEventBuffer[1][3]) * tickRate >= .000 do
      self:pack(unpack(self.importantEventBuffer[1]))
      table.remove(self.importantEventBuffer, 1)
    end

    self.host:broadcast(tostring(self.outStream), 0, 'reliable')
  end

  if #self.eventBuffer > 0 then
    self.outStream:clear()
    while #self.eventBuffer > 0 and (tick - self.eventBuffer[1][3]) * tickRate >= .000 do
      self:pack(unpack(self.eventBuffer[1]))
      table.remove(self.eventBuffer, 1)
    end

    self.host:broadcast(tostring(self.outStream), 1, 'unreliable')
  end
end
