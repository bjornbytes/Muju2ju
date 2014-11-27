require 'app/unit/unit'

UnitServer = extend(Unit)

function UnitServer:activate()
  self.target = nil
  self.attackTimer = 0
  self.buffs = {}
  self.shouldDestroy = false

  return Unit.activate(self)
end

function UnitServer:update()
  self.attackTimer = self.attackTimer - math.min(self.attackTimer, tickRate)

  table.each(self.buffs, function(entries, stat)
    table.each(entries, function(entry, i)
      entry.timer = timer.rot(entry.timer, function() table.remove(entries, i) end)
    end)
  end)

  if self.animation then self.animation:tick(tickRate) end

  return Unit.update(self)
end

