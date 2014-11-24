local Buju = extend(Unit)
Buju.code = 'buju'

Buju.width = 20
Buju.height = 50

Buju.maxHealth = 50
Buju.damage = 6
Buju.attackRange = 10
Buju.attackSpeed = .85
Buju.speed = 45

Buju.phaseExtraAttacks = 0
Buju.phaseLeapDistance = 0

function Buju:activate()
	Unit.activate(self)
end

function Buju:update()
  if ctx.tag == 'server' then
    Unit.update(self)

    -- Target Acquired
    self:selectTarget()
    if self.target and self.attackTimer == 0 and self:inRange() then self:attack() end

    -- Movement
    self:move()
  end
end

function Buju:attack()
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

function Buju:isTargetable(other)
  if other.owner.dead then return false end
  return true
end

return Buju

