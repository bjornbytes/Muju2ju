local Kuju = extend(Unit)
Kuju.code = 'kuju'

Kuju.width = 40
Kuju.height = 40

Kuju.maxHealth = 55
Kuju.maxHealthPerMinute = 7
Kuju.damage = 8
Kuju.damagePerMinute = 12
Kuju.attackRange = 165
Kuju.attackSpeed = .8
Kuju.speed = 45

function Kuju:activate()
	Unit.activate(self)
end

function Kuju:update()
  if ctx.tag == 'server' then
    Unit.update(self)

    -- Target Acquired
    self:selectTarget()
    if self.target and self.attackTimer == 0 and self:inRange() then self:attack() end

    -- Movement
    self:move()
  end
end

function Kuju:attack()
  local damage = self.damage

  -- The Works
  self.target:hurt(damage, self)
  self.target:addBuff('slow', '-10%', 1, self, 'kujuSlow')
  self.attackTimer = self.attackSpeed

  -- Sound
  ctx.event:emit('sound.play', {sound = 'combat', volume = .5, with = function(sound)
    local pitch = 1 + love.math.random() * .2
    if love.math.random() > .5 then pitch = 1 / pitch end
    sound:setPitch(pitch)
  end})
end

return Kuju
