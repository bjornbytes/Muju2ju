PlayerServer = extend(Player)

function PlayerServer:activate()
  self.history = {}
  self.ack = tick

  Player.activate(self)
end

function PlayerServer:get(t)
  if t == tick then return self end

  while self.history[1] and self.history[1].tick < tick - 2 / tickRate do
    table.remove(self.history, 1)
  end

  if #self.history == 0 then return self end

  if self.history[#self.history].tick < t then return self end

  for i = #self.history, 1, -1 do
    if self.history[i].tick <= t then return self.history[i] end
  end

  return self.history[1]
end

function PlayerServer:update()
  -- spawn timer decays here and only here, for example

  Player.update(self)
end

function PlayerServer:trace(data)
  if data.tick <= self.ack then return end -- Bail if we've processed data more recent than this data.

  self.ack = data.tick

  -- if not self.dead then?
  self:move(data)
  self:slot(data)

  table.insert(self.history, setmetatable({
    x = self.x,
    y = self.y,
    tick = data.tick
  }, self.meta))

  -- sync
  local msg = {}
  msg.x = math.round(self.x)
  msg.y = math.round(self.y)
  msg.health = math.round(self.health)
  msg.minion = self.selectedMinion

  msg.id = self.id
  msg.tick = tick
  msg.ack = self.ack

  ctx.net:emit(evtSync, msg)
end
