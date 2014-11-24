local Thuju = extend(Unit)
Thuju.code = 'thuju'

Thuju.width = 64
Thuju.height = 64

Thuju.maxHealth = 400
Thuju.damage = 17
Thuju.attackRange = 32
Thuju.attackSpeed = 1.667
Thuju.speed = 45

Thuju.tauntDuration = 2
Thuju.tauntCooldown = 10
Thuju.tauntRange = 150
Thuju.tauntMaxEnemies = 2
Thuju.tauntReflect = 0
Thuju.tauntArmor = 0

Thuju.smashCooldown = 12
Thuju.smashRange = 128
Thuju.smashStun = .75
Thuju.smashDamage = 10

function Thuju:activate()
	Unit.activate(self)

  self.animation = data.animation.thuju(self, {scale = self.scale})
  self.animation.flipX = self.owner and (not self.owner.animation.flipX) or false
end

function Thuju:update()
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

  -- Animation
  if ctx.tag == 'server' then
    self.animation:set('attack')
  end
end

function Thuju:hurt(amount, source)
  if source and source.team ~= self.team and self.taunting > 0 then
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

