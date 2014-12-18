Players = class()

function Players:init()
  self.players = {}
end

function Players:update()
  table.with(self.players, 'update')
end

function Players:keypressed(key)
  local p = ctx.id and self:get(ctx.id)
  if p and p.input then
    p.input:keypressed(key)
  end
end

function Players:keyreleased(key)
  local p = ctx.id and self:get(ctx.id)
  if p and p.input then
    p.input:keyreleased(key)
  end
end

function Players:mousepressed(x, y, b)
  local p = ctx.id and self:get(ctx.id)
  if p and p.input then
    p.input:mousepressed(x, y, b)
  end
end

function Players:add(id, vars)
  local player = self:get(id)
  if player then return player end
  local kind = ctx.tag == 'server' and PlayerServer or (id == ctx.id and PlayerMain or PlayerDummy)
  player = kind()
  player.id = id
  player.team = ctx.config.players[id].team
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
