local Thuju = extend(Unit)
Thuju.code = 'thuju'

Thuju.width = 64
Thuju.height = 64

Thuju.maxHealth = 150
Thuju.maxHealthPerMinute = 15
Thuju.damage = 9
Thuju.damagePerMinute = 6
Thuju.attackRange = 32
Thuju.attackSpeed = 1.5
Thuju.speed = 42

Thuju.tauntDuration = 2
Thuju.tauntMaxEnemies = 2
Thuju.tauntReflect = 0
Thuju.tauntArmor = 0

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

return Thuju

