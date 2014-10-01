Units = extend(Manager)
Units.manages = 'unit'

function Units:init()
  Manager.init(self)

  self.enemyLevel = 0
  self.enemyTimer = 5
  self.enemyTimerMin = 6
  self.enemyTimerMax = 9

  ctx.event:on('unitCreate', function(info)
    self:add(info.kind, {id = info.id, owner = ctx.players:get(info.owner), x = info.x, y = info.y})
  end)

  ctx.event:on('unitDestroy', function(info)
    self:remove(self.objects[info.id])
  end)
end

function Units:update()
  Manager.update(self)

  if ctx.tag == 'server' then
    self.enemyTimer = timer.rot(self.enemyTimer, function()
      local spawnType
      local x = love.math.random() > .5 and 0 or ctx.map.width

      spawnType = 'puju'
      if self.enemyTimerMax < 8 then
        if love.math.random() < math.min(8 - self.enemyMaxTimer, 2) * .06 then
          spawnType = 'spuju'
        end
      end

      ctx.net:emit('unitCreate', {id = self.nextId, owner = 0, kind = spawnType, x = x, y = 400})
      
      self.enemyTimerMin = math.max(self.enemyTimerMin - .055 * math.clamp(self.enemyTimerMin / 5, .1, 1), 1.4)
      self.enemyTimerMax = math.max(self.enemyTimerMax - .03 * math.clamp(self.enemyTimerMax / 4, .5, 1), 2.75)
      return self.enemyTimerMin + love.math.random() * (self.enemyTimerMax - self.enemyTimerMin)
    end)

    self.enemyLevel = self.enemyLevel + tickRate / (16 + self.enemyLevel / 2)
  end
end
