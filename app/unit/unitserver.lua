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
  self:hurt(10)

  return Unit.update(self)
end

function UnitServer:die()
  if not self.shouldDestroy then

    -- Create Juju
    local vx, vy = love.math.random(-35, 35), love.math.random(-300, -100)
    ctx.net:emit('jujuCreate', {id = ctx.jujus.nextId, x = math.round(self.x), y = math.round(self.y), team = self.owner and self.owner.team or 0, amount = 3 + love.math.random(0, 2), vx = vx, vy = vy})

    -- Set flag rather than removing (so death can still be sync'd -- Unit.die(self) will be called in sync)
    self.shouldDestroy = true
  end
end
