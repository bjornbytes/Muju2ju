Players = class()

function Players:init()
  self.players = {}

  ctx.event:on(evtLeave, function(data)
    self:remove(data.id)
  end)

  ctx.event:on(evtDeath, function(data)
    local p = self:get(data.id)
    if not p then return end
    p:die()
  end)

  ctx.event:on(evtSpawn, function(data)
    local p = self:get(data.id)
    if not p then return end
    p:spawn()
  end)
end

function Players:update()
  table.with(self.players, 'update')
end

function Players:add(id, vars)
  local kind = ctx.tag == 'server' and PlayerServer or (id == ctx.id and PlayerMain or PlayerDummy)
  local player = kind()
  player.id = id
  table.merge(vars, player, true)
  f.exe(player.activate, player)
  self.players[id] = player
  return player
end

function Players:remove(id)
  local player = self.players[id]
  if not player then return end
  f.exe(player.deactivate, player)
  self.players[id] = nil
  return player
end

function Players:get(id, t)
  if not id or not self.players[id] then return nil end
  return self.players[id]:get(t or tick)
end

function Players:each(fn)
  table.each(self.players, function(player, id)
    fn(self:get(id))
  end)
end
