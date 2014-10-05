local Zuju = extend(Unit)
Zuju.code = 'zuju'

Zuju.width = 48
Zuju.height = 48

Zuju.maxHealth = 80
Zuju.maxHealthPerMinute = 10
Zuju.damage = 9
Zuju.damagePerMinute = 10
Zuju.attackRange = 24
Zuju.attackSpeed = 1
Zuju.speed = 50

function Zuju:activate()
	Unit.activate(self)

  self.animation = data.animation.zuju(self, {scale = self.scale})
  self.animation.flipX = not self.owner.animation.flipX
end

function Zuju:update()
  if ctx.tag == 'server' then
    if self.animation:blocking() then
      self.dead = self.animation:current().name == 'death'
      self.x = self.x + self.knockBack * tickRate * 3000
      self.knockBack = math.max(0, math.abs(self.knockBack) - tickRate) * math.sign(self.knockBack)
      self.animation:tick(tickRate)
      return
    end

    Unit.update(self)

    -- Target Acquired
    self:selectTarget()
    if self.target and self.attackTimer == 0 and self:inRange() then self:attack() end

    -- Movement
    self:move()

    -- Animations
    if not self:inRange() then
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

function Zuju:attack()
  local damage = self.damage

  -- The Works
  self.target:hurt(damage, self)
  self.attackTimer = self.attackSpeed

  -- Sound
  ctx.event:emit('sound.play', {sound = 'combat', volume = .5, with = function(sound)
    local pitch = 1 + love.math.random() * .2
    if love.math.random() > .5 then pitch = 1 / pitch end
    sound:setPitch(pitch)
  end})
end

return Zuju
