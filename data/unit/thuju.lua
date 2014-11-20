local Thuju = extend(Unit)
Thuju.code = 'thuju'

Thuju.width = 64
Thuju.height = 64

Thuju.maxHealth = 150
Thuju.maxHealthPerMinute = 15
Thuju.damage = 9
Thuju.damagePerMinute = 6
Thuju.attackRange = 32
Thuju.attackSpeed = 2
Thuju.speed = 42

Thuju.tauntDuration = 2
Thuju.tauntCooldown = 10
Thuju.tauntRange = 150
Thuju.tauntMaxEnemies = 2
Thuju.tauntReflect = 0
Thuju.tauntArmor = 0

Thuju.smashRange = 128
Thuju.smashStun = .75
Thuju.smashDamage = 10

function Thuju:activate()
	Unit.activate(self)

  self.tauntCooldownTimer = 0
  self.taunting = 0 -- Timer indicating whether or not I am taunting things.

  self.animation = data.animation.thuju(self, {scale = self.scale})
  self.animation.flipX = self.owner and (not self.owner.animation.flipX) or false
end

function Thuju:update()
  if ctx.tag == 'server' then
    Unit.update(self)

    self.tauntCooldownTimer = timer.rot(self.tauntCooldownTimer)
    self.taunting = timer.rot(self.taunting)

    if self.tauntCooldownTimer == 0 then
      local targets = ctx.target:inRange(self, self.tauntRange, 'enemy', 'unit')
      local taunted = 0
      for i = 1, #targets do
        if not targets[i].tauntedBy then
          targets[i].tauntedBy = self
          targets[i].tauntTimer = self.tauntDuration
          taunted = taunted + 1
          if taunted == self.tauntMaxEnemies then break end
        end
      end

      if taunted > 0 then
        self.tauntCooldownTimer = self.tauntCooldown
        self.taunting = self.tauntDuration
      end
    end

    -- Target Acquired
    self:selectTarget()
    if self.target and self.attackTimer == 0 and self:inRange() then self:attack() end

    -- Movement
    self:move()

    -- Animations
    if self.target and not self:inRange() then
      self.animation:set('walk')
    end

    local current = self.animation:current()
    if current and current.name == 'walk' and self.target then
      self.animation.flipX = (self.target.x - self.x) < 0
    end
  end
end

function Thuju:attack()
  self.target:hurt(self.damage, self)
  self.attackTimer = self.attackSpeed

  -- Sound
  ctx.event:emit('sound.play', {sound = 'combat', volume = .5, with = function(sound)
    local pitch = 1 + love.math.random() * .2
    if love.math.random() > .5 then pitch = 1 / pitch end
    sound:setPitch(pitch)
  end})

  -- Animation
  if ctx.tag == 'server' then
    self.animation:set('attack')
  end
end

function Thuju:hurt(amount, source)
  if self.taunting > 0 and source.team ~= self.team then
    if self.tauntReflect > 0 then
      source:hurt(amount * self.tauntReflect, self)
    end

    if self.tauntArmor > 0 then
      amount = amount * (1 - self.tauntArmor)
    end
  end

  return Unit.hurt(self, amount, source)
end

return Thuju

