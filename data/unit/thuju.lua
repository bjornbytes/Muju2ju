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

function Thuju:activate()
	Unit.activate(self)
end

function Thuju:update()
  if ctx.tag == 'server' then
    Unit.update(self)

    -- Target Acquired
    self:selectTarget()
    if self.target and self.attackTimer == 0 and self:inRange() then self:attack() end

    -- Movement
    self:move()
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
end

return Thuju

