NetServer = extend(Net)

NetServer.messages = {}
NetServer.messages.join = {
  data = {
    id = 3
  },
  order = {'id'},
  important = true,
  receive = function(self, event)
    local pid = self.peerToPlayer[event.peer]
    self:send('join', event.peer, {id = pid})
    ctx.players:add(pid)
    ctx.players:get(pid).peer = event.peer
    print('player ' .. pid .. ' connected')
    if table.count(ctx.players.players) == playerCount then
      self:emit('ready', {tick = tick})
      self.state = 'playing'
    end
  end
}

NetServer.messages.leave = {
  data = {
    id = 3,
    reason = 'string'
  },
  order = {'id', 'reason'},
  important = true,
  receive = function(self, event)
    print(self.peerToPlayer[event.peer] .. ' left')
    -- self:emit etc.
  end
}

NetServer.messages.ready = {
  data = {
    tick = 16
  },
  order = {'tick'},
  important = true
}

NetServer.messages.input = {
  data = {
    ack = 16,
    x = 'float',
    juju = 12, 
    health = 8,
    ghostX = 'float',
    ghostY = 'float'
  },
  delta = {{'x', 'health'}, {'ghostX', 'ghostY'}},
  order = {'ack', 'x', 'juju', 'health', 'ghostX', 'ghostY'},
  receive = function(self, event)
    ctx.players:get(self.peerToPlayer[event.peer]):trace(event.data)
  end
}

NetServer.messages.snapshot = {
  data = {
    tick = 16,
    players = {
      id = 3,
      x = 'float',
      health = 8,
      animationIndex = 3,
      animationPrev = 3,
      animationTime = 'float',
      animationPrevTime = 'float',
      animationAlpha = 'float',
      animationFlip = 'bool',
      ghostX = 'float',
      ghostY = 'float',
      ghostAngle = 9
    },
    units = {
      id = 12,
      x = 16,
      y = 16,
      health = 10
    }
  },
  delta = {
    players = {
      {'x', 'health'},
      {'ghostX', 'ghostY', 'ghostAngle'}
    },
    units = {'x', 'y', 'health'}
  },
  order = {
    'tick', 'players', 'units',
    players = {
      'id', 'x', 'health',
      'animationIndex', 'animationPrev', 'animationTime', 'animationPrevTime', 'animationAlpha', 'animationFlip',
      'ghostX', 'ghostY', 'ghostAngle'
    },
    units = {'id', 'x', 'y', 'health'}
  }
}

NetServer.messages.unitCreate = {
  data = {
    id = 12,
    owner = 3,
    kind = 'string',
    x = 16,
    y = 16
  },
  order = {'id', 'owner', 'kind', 'x', 'y'},
  important = true
}

NetServer.messages.unitDestroy = {
  data = {
    id = 12
  },
  order = {'id'},
  important = true
}

NetServer.messages.jujuCreate = {
  data = {
    id = 12,
    x = 16,
    y = 16
  },
  order = {'id', 'x', 'y'},
  important = true
}

NetServer.messages.jujuDestroy = {
  data = {
    id = 12
  },
  order = {'id'},
  important = true
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
  self:emit('leave', {id = pid, reason = reason})
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
  local buffer = self.messages[evt].important and self.importantEventBuffer or self.eventBuffer
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
