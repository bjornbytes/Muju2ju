require 'app/unit/unit'

UnitServer = extend(Unit)

function UnitServer:activate()
  self.target = nil
  self.attackTimer = 0
  self.buffs = {}

  Unit.activate(self)

  self.animation:on('event', function(data)
    if data.data.name == 'attack' then
      if self.target then
        self.target:hurt(self.damage, self)
      end
    end
  end)

  self.animation:on('complete', function(data)
    if data.state.name == 'death' then
      ctx.net:emit('unitDie', {id = self.id})
    end
  end)
end

function UnitServer:update()
  self.animation:tick(tickRate)
  self:hurt(10)

  return Unit.update(self)
end

function UnitServer:hurt(amount, source)
  if self.dying then return end

  self.health = self.health - amount

  if self.health <= 0 then
    self.animation:set('death', {force = true})
    self.dying = true
    return true
  end
end

function UnitServer:heal(amount, source)
  if self.dying then return end

  self.health = math.min(self.health + amount, self.maxHealth)
end

function UnitServer:die()
  ctx.net:emit('jujuCreate', {
    id = ctx.jujus.nextId,
    x = math.round(self.x),
    y = math.round(self.y),
    team = self.owner and self.owner.team or 0,
    amount = 3 + love.math.random(0, 2),
    vx = love.math.random(-35, 35),
    vy = love.math.random(-300, -100)
  })

  return Unit.die(self)
end
