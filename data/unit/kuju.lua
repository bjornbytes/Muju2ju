local Kuju = extend(Unit)
Kuju.code = 'kuju'

Kuju.width = 40
Kuju.height = 40

Kuju.maxHealth = 300
Kuju.damage = 15
Kuju.attackRange = 185
Kuju.attackSpeed = 1.667
Kuju.speed = 40

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
  self.attackTimer = self.attackSpeed
end

return Kuju
