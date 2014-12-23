NetServer = extend(Net)

NetServer.messages = {}
NetServer.messages.join = {
  data = {
    id = Net.sizes.playerId,
    problem = 'string'
  },
  order = {'id', 'problem'},
  important = true,
  receive = function(self, event)
    local username = event.data.username

    local user, id
    for i = 1, #ctx.config.players do
      if ctx.config.players[i].username == username then
        id = i
        user = ctx.config.players[i]
        break
      end
    end

    if table.has(arg, 'test') and table.count(ctx.players.players) == 1 then
      id = 2
      user = ctx.config.players[2]
    end

    if not user then
      self:send('join', event.peer, {id = 0, problem = 'username'})
      event.peer:disconnect_later()
      return
    end

    local ip = tostring(event.peer):sub(1, tostring(event.peer):find(':') - 1)
    if user.ip ~= ip then
      self:send('join', event.peer, {id = 0, problem = 'ip'})
      event.peer:disconnect_later()
      return
    end

    print('player ' .. id .. ' connected')
    self.peerToPlayer[event.peer] = id
    self:send('join', event.peer, {id = id, problem = ''})
    self:emit('chat', {message = username .. ' has joined the game!'})

    -- Create their player (if not created already) and associate this peer with the player.
    ctx.players:add(id)
    ctx.players:get(id).peer = event.peer

    -- If everyone has joined, we either start the game or bootstrap this peer.
    if table.count(ctx.players.players) == #ctx.config.players then
      if self.state ~= 'playing' then
        self:emit('ready', {tick = tick})
        self.state = 'playing'
      else
        self:bootstrap(event.peer)
      end
    end
  end
}

NetServer.messages.leave = {
  data = {
    id = Net.sizes.playerId,
    reason = 'string'
  },
  order = {'id', 'reason'},
  important = true,
  receive = function(self, event)
    self:disconnect(event)
  end
}

NetServer.messages.ready = {
  data = {
    tick = Net.sizes.tick
  },
  order = {'tick'},
  important = true
}

NetServer.messages.over = {
  data = {
    winner = Net.sizes.teamId
  },
  order = {'winner'},
  important = true
}

NetServer.messages.rewards = {
  data = {
    runes = {id = 5, token = 'string'},
    units = {code = 'string'}
  },
  order = {
    'runes', 'units',
    runes = {'id', 'token'},
    units = {'code'}
  },
  important = true
}

NetServer.messages.bootstrap = {
  data = {
    tick = Net.sizes.tick,
    players = {
      color = 'string',
      id = Net.sizes.playerId,
      x = 'float'
    },
    units = {
      id = Net.sizes.unitId,
      owner = Net.sizes.playerId,
      kind = 'string',
      x = 16
    }
  },
  order = {
    'tick', 'players', 'units',
    players = {'id', 'x'},
    units = {'id', 'owner', 'kind', 'x'}
  },
  important = true
}

NetServer.messages.input = {
  data = {
    ack = Net.sizes.tick,
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
    tick = Net.sizes.tick,
    players = {
      id = Net.sizes.playerId,
      x = 'float',
      health = 8,
      animationIndex = Net.sizes.playerAnimationIndex,
      flipped = 'bool',
      dead = 'bool',
      ghostX = 'float',
      ghostY = 'float',
      ghostAngle = 9
    },
    units = {
      id = Net.sizes.unitId,
      x = 16,
      health = 8,
      dying = 'bool',
      animationIndex = Net.sizes.unitAnimationIndex,
      flipped = 'bool'
    },
    shrines = {
      id = 4,
      health = 'float'
    }
  },
  delta = {
    players = {
      {'x', 'health'},
      {'ghostX', 'ghostY', 'ghostAngle'}
    }
  },
  order = {
    'tick', 'players', 'units', 'shrines',
    players = {'id', 'x', 'health', 'animationIndex', 'flipped', 'dead', 'ghostX', 'ghostY', 'ghostAngle' },
    units = {'id', 'x', 'health', 'dying', 'animationIndex', 'flipped'},
    shrines = {'id', 'health'}
  }
}

NetServer.messages.chat = {
  data = {
    message = 'string'
  },
  order = {'message'},
  important = true,
  receive = function(self, event)
    local id = self.peerToPlayer[event.peer]
    if not id then return end
    local username = ctx.config.players[id].username
    ctx.players:each(function(player)
      if player and player.peer then
        self:send('chat', player.peer, {message = '{' .. (player.team == ctx.config.players[id].team and 'green' or 'red') .. '}' .. username .. '{white}: ' .. event.data.message})
      end
    end)
  end
}

NetServer.messages.unitCreate = {
  data = {
    id = Net.sizes.unitId,
    owner = Net.sizes.playerId,
    kind = 'string',
    x = 16
  },
  order = {'id', 'owner', 'kind', 'x'},
  important = true
}

NetServer.messages.unitDie = {
  data = {
    tick = Net.sizes.tick,
    id = Net.sizes.unitId
  },
  order = {'tick', 'id'},
  important = true
}

NetServer.messages.unitAbility = {
  data = {
    id = Net.sizes.unitId,
    tick = Net.sizes.tick,
    ability = Net.sizes.unitAbility
  },
  order = {'id', 'tick', 'ability'},
  important = true
}

NetServer.messages.jujuCreate = {
  data = {
    id = 12,
    team = Net.sizes.team,
    x = 16,
    y = 16,
    amount = 8,
    vx = 'float',
    vy = 'float'
  },
  order = {'id', 'team', 'x', 'y', 'amount', 'vx', 'vy'},
  important = true
}

NetServer.messages.jujuCollect = {
  data = {
    id = 12,
    owner = 3
  },
  order = {'id', 'owner'},
  important = true
}

function NetServer:init()
  self.other = NetClient
  self.state = 'waiting'

  self:listen(ctx.config.port)
  self.peerToPlayer = {}
  self.eventBuffer = {}
  self.importantEventBuffer = {}

  ctx.event:on('game.quit', f.cur(self.quit, self))
  ctx.event:on('over', function(data)
    if table.has(arg, 'test') then
      self:quit()
      Context:remove(ctx)
      Context:add(Server, ctx.config)
      return
    end

    local winners = table.filter(ctx.config.players, function(player) return player.team == data.winner end)
    local losers = table.filter(ctx.config.players, function(player) return player.team ~= data.winner end)
    winners = table.values(table.map(winners, function(winner) return winner.username end))
    losers = table.values(table.map(losers, function(loser) return loser.username end))

    local json = require 'lib/deps/dkjson'
    local hub = require('socket').tcp()
    assert(socket and json and hub)
    assert(hub:connect('127.0.0.1', 7999))
    print('connected')
    local req = json.encode({cmd = 'gameOver', payload = {token = ctx.config.token, winners = winners, losers = losers}})
    print('sent gameover')
    assert(req)
    hub:send(req .. '\n')
    local line  = hub:receive('*l')
    print(line)
    assert(line)
    local res = json.decode(line)
    assert(res.cmd == 'rewards')
    assert(res.payload)
    hub:close()

    for i = 1, self.host:peer_count() do
      local peer = self.host:get_peer(i)
      local player = peer and self.peerToPlayer[peer]
      if peer and player then
        local username = ctx.config.players[player].username
        local rewards = username and res.payload[username]
        if rewards then
          self:send('rewards', peer, rewards)
        end
      end
    end
  end)

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
  event.peer:timeout(0, 0, 3000)
  event.peer:ping()
end

function NetServer:disconnect(event)
  local pid = self.peerToPlayer[event.peer]
  if pid then
    print('player ' .. pid .. ' disconnected')
    local reason = event.reason or 'left'
    self:emit('leave', {id = pid, reason = reason})
  end
  self.peerToPlayer[event.peer] = nil
  event.peer:disconnect_now()

  if table.count(self.peerToPlayer) == 0 then
    if table.has(arg, 'test') then
      self:quit()
      Context:remove(ctx)
      Context:add(Server, ctx.config)
    else
      if self.state == 'ending' then
        self:quit()
        love.event.quit()
      else
        -- Uh, guys?
      end
    end
  end
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

function NetServer:snapshot()
  local snapshot = {tick = tick, players = {}, units = {}, shrines = {}}

  ctx.players:each(function(player)
    local entry = {
      id = player.id,
      dead = player.dead,
      animationIndex = player.animation.state.index,
      flipped = player.animation.flipped
    }

    if player.dead then
      entry.ghostX = player.ghostX
      entry.ghostY = player.ghostY
      
      local angle = math.round(math.deg(player.ghost.angle))
      while angle < 0 do angle = angle + 360 end
      entry.ghostAngle = angle
    else
      entry.x = player.x
      entry.health = math.round(player.health / player.maxHealth * 255)
    end

    table.insert(snapshot.players, entry)
  end)

  ctx.units:each(function(unit)
    table.insert(snapshot.units, {
      id = unit.id,
      x = math.round(unit.x),
      health = math.round(unit.health / unit.maxHealth * 255),
      dying = unit.dying,
      animationIndex = unit.animation.state.index,
      flipped = unit.animation.flipped
    })
  end)

  ctx.shrines:each(function(shrine)
    table.insert(snapshot.shrines, {
      id = shrine.id,
      health = shrine.health / shrine.maxHealth
    })
  end)

  self:emit('snapshot', snapshot)
end

function NetServer:bootstrap(peer)
  if not peer or not self.peerToPlayer[peer] then return end

  local message = {tick = tick, players = {}, units = {}}
  
  ctx.players:each(function(p)
    table.insert(message.players, {id = p.id, x = p.x})
  end)

  ctx.units:each(function(unit)
    table.insert(message.units, {id = unit.id, owner = unit.owner and unit.owner.id or 0, kind = unit.code, x = unit.x})
  end)

  return self:send('bootstrap', peer, message)
end
