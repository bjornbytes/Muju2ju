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
        self.buffs:preattack(self.target, self.damage)
        local amount = self.target:hurt(self.damage, self, 'attack')
        self.buffs:postattack(self.target, amount)
      end
    end
  end)

  self.animation:on('complete', function(data)
    if data.state.name == 'death' then
      ctx.net:emit('unitDie', {tick = tick, id = self.id})
      self:die()
    end
  end)
end

function UnitServer:update()
  self.animation:tick(tickRate)

  return Unit.update(self)
end

function UnitServer:hurt(amount, source, kind)
  if self.dying then return end

  amount = self.buffs:prehurt(amount, source, kind)

  self.health = self.health - amount

  self.buffs:posthurt(amount, source, kind)

  if self.health <= 0 then
    self.animation:set('death', {force = true})
    self.dying = true
  end

  if love.math.random() < .05 then
    ctx.net:emit('jujuCreate', {
      id = ctx.jujus.nextId,
      x = math.round(self.x),
      y = math.round(self.y),
      team = self.player and self.player.team or 0,
      amount = 10 + love.math.random(0, 2),
      vx = love.math.random(-35, 35),
      vy = love.math.random(-300, -100)
    })
  end

  return amount
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
    team = self.player and self.player.team or 0,
    amount = 10 + love.math.random(0, 2),
    vx = love.math.random(-35, 35),
    vy = love.math.random(-300, -100)
  })

  return Unit.die(self)
end
