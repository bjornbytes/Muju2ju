local Guju = extend(Unit)
Guju.code = 'guju'

Guju.width = 64
Guju.height = 48

Guju.maxHealth = 100
Guju.damage = 6
Guju.attackRange = 96
Guju.attackSpeed = 1.4
Guju.speed = 35

function Guju:activate()
	Unit.activate(self)
end

function Guju:update()
  if ctx.tag == 'server' then
    Unit.update(self)

    -- Target Acquired
    self:selectTarget()
    if self.target and self.attackTimer == 0 and self:inRange() then self:attack() end

    -- Movement
    self:move()
  end
end

function Guju:attack()
  local damage = self.damage

  -- The Works
  local targets = ctx.target:inRange(self, self.attackRange, 'enemy', 'unit')
  table.each(targets, function(target)
    if math.sign(target.x - self.x) == math.sign(self.target.x - self.x) then
      target:hurt(damage, self)
    end
  end)
  self.attackTimer = self.attackSpeed

  -- Sound
  ctx.event:emit('sound.play', {sound = 'combat', volume = .5, with = function(sound)
    local pitch = 1 + love.math.random() * .2
    if love.math.random() > .5 then pitch = 1 / pitch end
    sound:setPitch(pitch)
  end})
end

return Guju
