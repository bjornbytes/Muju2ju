local Bruju = extend(Unit)
Bruju.code = 'bruju'

Bruju.width = 48
Bruju.height = 48

Bruju.maxHealth = 80
Bruju.maxHealthPerMinute = 10
Bruju.damage = 9
Bruju.damagePerMinute = 10
Bruju.attackRange = 24
Bruju.attackSpeed = 1
Bruju.speed = 50

Bruju.burstDamage = 15
Bruju.burstRange = 90
Bruju.burstHeal = 0

Bruju.safeguardThreshold = .25
Bruju.safeguardAmount = .25
Bruju.safeguardDuration = 3
Bruju.safeguardThorns = 0
Bruju.safeguardHeal = 0

Bruju.retaliationDamage = 10
Bruju.retaliationLifesteal = 0
Bruju.retaliationAttackSpeed = 0
Bruju.retaliationSpeed = 0

function Bruju:activate()
	Unit.activate(self)

  self.animation = data.animation.bruju(self, {scale = self.scale})
  self.animation.flipX = not self.owner.animation.flipX
end

function Bruju:update()
  if ctx.tag == 'server' then
    if self.animation:blocking() then
      self.dead = self.animation:current().name == 'death'
      self.x = self.x + self.knockBack * tickRate * 3000
      self.knockBack = math.max(0, math.abs(self.knockBack) - tickRate) * math.sign(self.knockBack)
      self.animation:tick(tickRate)
      return
    end

    if self.owner.deck[self.code].upgrades.retaliation then
      self:addBuff('damage', (1 - (self.health / self.maxHealth)) * Bruju.retaliationDamage, 1, self, 'retaliationDamage')
      self:addBuff('lifesteal', (1 - (self.health / self.maxHealth)) * Bruju.retaliationLifesteal, 1, self, 'retaliationLifesteal')
      self:addBuff('attackSpeed', (1 - (self.health / self.maxHealth)) * Bruju.retaliationAttackSpeed, 1, self, 'retaliationAttackSpeed')
      self:addBuff('speed', (1 - (self.health / self.maxHealth)) * Bruju.retaliationSpeed, 1, self, 'retaliationSpeed')
    end

    Unit.update(self)

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
