NetClient = extend(Net)

NetClient.messages = {}
NetClient.messages.join = {
  important = true,
  receive = function(self, event)
    ctx.id = event.data.id
    ctx.players:add(ctx.id)
  end
}

NetClient.messages.leave = {
  important = true
}

NetClient.messages.ready = {
  receive = function(self, event)
    ctx.tick = event.data.tick
    self.state = 'playing'
    for i = 1, playerCount do
      if i ~= ctx.id then
        ctx.players:add(i)
      end
    end

    ctx.event:emit('ready')
  end
}

NetClient.messages.input = {
  data = {
    tick = 16,
    x = 'float',
    y = 'float',
    summon = 'bool',
    minion = 3
  },
  delta = {{'x', 'y'}},
  order = {'tick', 'x', 'y', 'summon', 'minion'},
  receive = function(self, event)
    ctx.players:get(ctx.id):trace(event.data)
  end
}

NetClient.messages.snapshot = {
  receive = function(self, event)
    table.each(event.data.players, function(data)
      local p = ctx.players:get(data.id)
      
      if p then
        if p.id ~= ctx.id then
          data.tick = event.data.tick
          p:trace(data)
        end
      end

      if data.dead then
        if not p.dead then p:die() end
      elseif p.dead then
        p:spawn()
      end
    end)

    table.each(event.data.units, function(data)
      data.tick = event.data.tick
      local unit = ctx.units.objects[data.id]
      if unit then
        unit.history:add({
          tick = data.tick,
          x = data.x,
          y = data.y,
          health = data.health
        })
        unit.x = data.x
        unit.y = data.y
        unit.health = data.health
      end
    end)
  end
}

NetClient.messages.unitCreate = {
  receive = function(self, event)
    ctx.event:emit('unitCreate', event.data)
  end
}

NetClient.messages.unitDestroy = {
  receive = function(self, event)
    ctx.event:emit('unitDestroy', event.data)
  end
}

NetClient.messages.jujuCreate = {
  receive = function(self, event)
    ctx.event:emit('jujuCreate', event.data)
  end
}

NetClient.messages.jujuDestroy = {
  receive = function(self, event)
    ctx.event:emit('jujuDestroy', event.data)
  end
}

function NetClient:init()
  self.other = NetServer
  self.state = 'connecting'
  local ip = arg[2] == 'local' and '127.0.0.1' or '123.123.123.123'
  self:connectTo(ip, 6061)
  self.messageBuffer = {}

  ctx.event:on('game.quit', f.cur(self.quit, self))

  Net.init(self)
end

function NetClient:quit()
  self:send('leave')
  if self.host then self.host:flush() end
  if self.server then self.server:disconnect() end
end

function NetClient:connect(event)
  self.state = 'waiting'
  self.server = event.peer
  self:send('join')
  event.peer:ping()
end

function NetClient:disconnect(event)
  ctx.event:emit('game.quit')
end

function NetClient:send(msg, data)
  if not self.server then return end
  
  self.outStream:clear()
  self:pack(msg, data)

  local important = self.messages[msg].important
  local channel = important and 0 or 1
  local reliability = important and 'reliable' or 'unreliable'
  self.server:send(tostring(self.outStream), channel, reliability)
end

NetClient.emit = f.empty
