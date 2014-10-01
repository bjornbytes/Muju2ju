Units = extend(Manager)
Units.manages = 'unit'

function Units:init()
  Manager.init(self)

	self.enemyLevel = 0
	self.enemyTimer = 5
	self.enemyTimerMin = 6
	self.enemyTimerMax = 9

  self.nextId = 1
end

function Units:update()
	self.enemyTimer = timer.rot(self.enemyTimer, function()
    local spawnType
    local x = love.math.random() > .5 and 0 or ctx.map.width

    spawnType = 'puju'
    if self.enemyTimerMax < 8 then
      if love.math.random() < math.min(8 - self.enemyMaxTimer, 2) * .06 then
        spawnType = 'spuju'
      end
    end

    --ctx.net:emit(evtUnitSpawn, {id = self.nextId, tick = tick, owner = 0, kind = spawnType, x = x, y = 400})
    self.enemyTimerMin = math.max(self.enemyTimerMin - .055 * math.clamp(self.enemyTimerMin / 5, .1, 1), 1.4)
    self.enemyTimerMax = math.max(self.enemyTimerMax - .03 * math.clamp(self.enemyTimerMax / 4, .5, 1), 2.75)
		return self.enemyTimerMin + love.math.random() * (self.enemyTimerMax - self.enemyTimerMin)
	end)

  Manager.update(self)

  --[[
  -- sync
  --]]
  local msg = {tick = tick}
  msg.units = {}
  self:each(function(unit)
    table.insert(msg.units, {
      id = unit.id,
      x = unit.x,
      y = unit.y,
      health = math.round(unit.health)
    })
  end)
  --ctx.net:emit(evtUnitSync, msg)

	self.enemyLevel = self.enemyLevel + tickRate / (16 + self.enemyLevel / 2)
end

function Units:remove(unit)
  f.exe(unit.deactivate, unit)
  self.objects[unit.id] = nil
  unit = nil
end

function Units:add(kind, vars)
  self.nextId = self.nextId + 1
  if self.nextId > 1023 then self.nextId = 1 end
  local unit = data.unit[kind]()
  table.merge(vars, unit, true)
  f.exe(unit.activate, unit)
  self.objects[unit.id] = unit
end
