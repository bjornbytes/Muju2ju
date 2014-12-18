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
  self.animation:tick(tickRate)

  return Unit.update(self)
end
