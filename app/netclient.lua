NetClient = extend(Net)

NetClient.messages = {}
NetClient.messages.join = {
  data = {
    username = 'string'
  },
  order = {'username'},
  important = true,
  receive = function(self, event)
    if event.data.id == 0 then
      error('Unable to join game because: ' .. event.data.problem)
    end

    ctx.id = event.data.id
    ctx.players:add(ctx.id)
  end
}

NetClient.messages.leave = {
  data = {},
  order = {},
  important = true
}

NetClient.messages.ready = {
  receive = function(self, event)
    if self.state == 'playing' then return end

    ctx.tick = event.data.tick
    self.state = 'playing'
    for i = 1, #ctx.config.players do
      if i ~= ctx.id then
        ctx.players:add(i)
      end
    end

    ctx.event:emit('ready')
  end
}

NetClient.messages.over = {
  receive = function(self, event)
    ctx.event:emit('over', event.data)
  end
}

NetClient.messages.rewards = {
  receive = function(self, event)
    ctx.event:emit('rewards', event.data)
  end
}

NetClient.messages.bootstrap = {
  receive = function(self, event)

    -- Start the game if it isn't started already
    self.messages.ready.receive(self, event)

    table.each(event.data.players, function(data)
      local p = ctx.players:add(data.id)
      if p then p.x = data.x end
    end)

    table.each(event.data.units, function(data)
      data.tick = event.data.tick
      local unit = ctx.units:get(data.id)
      if not unit then
        ctx.event:emit('unitCreate', data)
        unit = ctx.units:get(data.id)
      end

      if unit then
        unit.x = data.x
      end
    end)
  end
}

NetClient.messages.input = {
  data = {
    tick = 16,
    x = 'float',
    y = 'float',
    summon = 'bool',
    selected = 2,
    stance = 2,
    ability = 2,
    target = 10
  },
  delta = {{'x', 'y'}, 'selected', 'stance', 'ability', 'target'},
  order = {'tick', 'x', 'y', 'summon', 'selected', 'stance', 'ability', 'target'},
  receive = function(self, event)
    ctx.players:get(ctx.id):trace(event.data)
  end
}

NetClient.messages.snapshot = {
  receive = function(self, event)
    if self.state ~= 'playing' then return end

    table.each(event.data.players, function(data)
      local p = ctx.players:get(data.id)

      if p then
        if data.dead then
          if not p.dead then p:die() end
        elseif p.dead then
          p:spawn()
        end
      
        if p.id ~= ctx.id then
          data.tick = event.data.tick
          p:trace(data)
        end
      end
    end)

    table.each(event.data.units, function(data)
      data.tick = event.data.tick
      local unit = ctx.units:get(data.id)
      if unit then
        unit.history:add({
          tick = data.tick,
          x = data.x,
          health = data.health / 255 * unit.maxHealth,
          dying = data.dying,
          animationIndex = data.animationIndex,
          flipped = data.flipped
        })
      end
    end)

    table.each(event.data.shrines, function(data)
      local shrine = ctx.shrines:get(data.id)
      if shrine then
        shrine.history:add({
          tick = event.data.tick,
          health = data.health * shrine.maxHealth
        })
        if shrine.health > data.health * shrine.maxHealth then shrine.lastHurt = tick end
        shrine.health = data.health * shrine.maxHealth
      end
    end)
  end
}

NetClient.messages.chat = {
  data = {message = 'string'},
  order = {'message'},
  important = true,
  receive = function(self, event)
    ctx.event:emit('chat', event.data)
  end
}

NetClient.messages.unitCreate = {
  receive = function(self, event)
    ctx.event:emit('unitCreate', event.data)
  end
}

NetClient.messages.unitDie = {
  receive = function(self, event)
    local unit = ctx.units:get(event.data.id)
    if unit then
      event.data.kind = 'death'
      table.insert(unit.eventQueue, event.data)
    end
  end
}

NetClient.messages.unitAbility = {
  receive = function(self, event)
    local unit = ctx.units:get(event.data.id)
    if unit then
      event.data.kind = 'ability'
      table.insert(unit.eventQueue, event.data)
    end
  end
}

NetClient.messages.jujuCreate = {
  receive = function(self, event)
    ctx.event:emit('jujuCreate', event.data)
    local juju = ctx.jujus:get(event.data.id)
    if juju then
      for i = 1, (self.server:round_trip_time() / 1000) / tickRate do
        juju:update()
      end
    end
  end
}

NetClient.messages.jujuCollect = {
  receive = function(self, event)
    ctx.event:emit('jujuCollect', event.data)
  end
}

NetClient.messages.upgrade = {
  data = {
    unit = 2,
    ability = 2,
    upgrade = 2,
    rune = 3,
    other = 'string'
  },
  delta = {'unit', 'ability', 'upgrade', 'rune', 'other'},
  order = {'unit', 'ability', 'upgrade', 'rune', 'other'},
  important = true,
  receive = function(self, event)
    ctx.upgrades:process(event.data, ctx.players:get(event.data.id))
  end
}

function NetClient:init()
  self.other = NetServer
  self.state = 'connecting'
  self:connectTo(ctx.config.ip, ctx.config.port)
  self.messageBuffer = {}

  ctx.event:on('game.quit', f.cur(self.quit, self))

  Net.init(self)
end

function NetClient:quit()
  self:send('leave', {})
  if self.host then self.host:flush() end
  if self.server then self.server:disconnect() end
end

function NetClient:connect(event)
  self.state = 'waiting'
  self.server = event.peer
  self:send('join', {username = ctx.user.username})
  event.peer:ping()
end

function NetClient:disconnect(event)
  if not self.server then
    print('Unable to connect to server')
  elseif self.state ~= 'ending' then
    ctx.event:emit('game.quit')
    print('Lost connection to server')
  end

  Context:add(Menu, ctx.user)
  Context:remove(ctx)
end

function NetClient:send(msg, data)
  if not self.server or not self.messages[msg] then return end
  
  self.outStream:clear()
  self:pack(msg, data)

  local important = self.messages[msg].important
  local channel = important and 0 or 1
  local reliability = important and 'reliable' or 'unreliable'
  self.server:send(tostring(self.outStream), channel, reliability)
  self.host:flush()
end

NetClient.emit = f.empty
