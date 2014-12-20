require 'app/unit/unit'

UnitServer = extend(Unit)

function UnitServer:activate()
  self.target = nil
  self.attackTimer = 0
  self.buffs = {}
  self.shouldDestroy = false

  Unit.activate(self)

  self.animation:on('event', function(event)
    if event.data.name == 'attack' then
      if self.target then
        self.target:hurt(self.damage, self)
      end
    end
  end)
end

function UnitServer:update()
  self.animation:tick(tickRate)

  return Unit.update(self)
end
