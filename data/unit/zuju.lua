local Zuju = extend(Unit)
Zuju.code = 'zuju'

Zuju.width = 32
Zuju.height = 48

Zuju.maxHealth = 65
Zuju.maxHealthPerMinute = 7
Zuju.damage = 5
Zuju.damagePerMinute = 6
Zuju.attackRange = 125
Zuju.attackSpeed = 1.5
Zuju.speed = 40

function Zuju:activate()
	Unit.activate(self)
end

function Zuju:update()
	Unit.update(self)

  -- Target Acquired
	self:selectTarget()
	if self.target and self.attackTimer == 0 and self:inRange() then self:attack() end

  -- Movement
  self:move()
end

function Zuju:attack()
  self.target.weaken = .5
  self.attackTimer = self.attackSpeed
end

return Zuju
