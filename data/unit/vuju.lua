local Vuju = extend(Unit)
Vuju.code = 'vuju'

Vuju.width = 32
Vuju.height = 48

Vuju.maxHealth = 65
Vuju.maxHealthPerMinute = 7
Vuju.damage = 5
Vuju.damagePerMinute = 6
Vuju.attackRange = 125
Vuju.attackSpeed = 1.5
Vuju.speed = 40

function Vuju:activate()
	Unit.activate(self)
end

function Vuju:update()
	Unit.update(self)

  -- Target Acquired
	self:selectTarget()
	if self.target and self.attackTimer == 0 and self:inRange() then self:attack() end

  -- Movement
  self:move()
end

function Vuju:attack()
  self.target.weaken = .5
  self.attackTimer = self.attackSpeed
end

return Vuju
