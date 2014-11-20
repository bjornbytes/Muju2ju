local Bruju = extend(Unit)
Bruju.code = 'bruju'

Bruju.width = 48
Bruju.height = 48

Bruju.maxHealth = 140
Bruju.maxHealthPerMinute = 10
Bruju.damage = 9
Bruju.damagePerMinute = 10
Bruju.attackRange = 24
Bruju.attackSpeed = 1.6
Bruju.speed = 50

Bruju.burstDamage = 0
Bruju.burstRange = 90
Bruju.burstHeal = 0

Bruju.rewindChance = 0
Bruju.rewindHealthFactor = .2 -- Chance scales based on missing health
Bruju.rewindReflect = .5
Bruju.rewindKnockback = .2

function Bruju:activate()
	Unit.activate(self)

  self.animation = data.animation.bruju(self, {scale = self.scale})
  self.animation.flipX = not self.owner.animation.flipX

  self.rewind = 0
end

function Bruju:update()
  if ctx.tag == 'server' then
    Unit.update(self)

    if self.animation:blocking() then return end

    -- Target Acquired
    self:selectTarget()
    if self.target and self.attackTimer == 0 and self:inRange() then self:attack() end

    -- Movement
    self:move()

    -- Animations
    if self.target and not self:inRange() then
      self.animation:set('walk')
    elseif self.target == ctx.shrine then
      self.animation:set('idle')
    end

    local current = self.animation:current()
    if current and current.name == 'walk' and self.target then
      self.animation.flipX = (self.target.x - self.x) < 0
    end

    if self.rewind > 0 then
      local amount = math.min(self.rewind, self.maxHealth * .5 * tickRate)
      self.health = math.min(self.health + amount, self.maxHealth)
      self.rewind = self.rewind - amount
    end
  else
    return Unit.update(self)
  end
end

function Bruju:die()
  self:burst()
  Unit.die(self)
end

function Bruju:attack()
  local damage = self.damage

  -- The Works
  self.target:hurt(self:getStat('damage'), self)
  self.attackTimer = self.attackSpeed

  -- Sound
  ctx.event:emit('sound.play', {sound = 'combat', volume = .5, with = function(sound)
    local pitch = 1 + love.math.random() * .2
    if love.math.random() > .5 then pitch = 1 / pitch end
    sound:setPitch(pitch)
  end})
end

function Bruju:hurt(amount, source)
  if source and love.math.random() < self.rewindChance + (1 - (self.health / self.maxHealth)) * self.rewindHealthFactor then
    self.rewind = self.rewind + amount

    if source and self.rewindReflect > 0 then
      source:hurt(amount * self.rewindReflect, self)
      source.knockback = self.rewindKnockback * math.sign(source.x - self.x)
    end
  end

  return Unit.hurt(self, amount, source)
end

function Bruju:burst()
  t = t or tick
  if self.owner.deck[self.code].upgrades.burst then
    ctx.net:emit('spellCreate', {
      properties = {
        kind = 'burst',
        owner = self.owner,
        x = self.x,
        y = self.y,
        radius = self.burstRange,
        damage = self.burstDamage,
        heal = self.burstHeal
      }
    })
  end
end

return Bruju
