local Vuju = extend(Unit)
Vuju.code = 'vuju'

Vuju.width = 40
Vuju.height = 48

Vuju.maxHealth = 60
Vuju.maxHealthPerMinute = 9
Vuju.damage = 0
Vuju.damagePerMinute = 0
Vuju.attackRange = 200
Vuju.attackSpeed = 1.5
Vuju.speed = 50

function Vuju:activate()
	Unit.activate(self)
end

function Vuju:update()
  if ctx.tag == 'server' then
    Unit.update(self)

    -- Target Acquired
    self:selectTarget()
    if self.target and self.attackTimer == 0 and self:inRange() then self:attack() end

    -- Movement
    self:move()
  end
end

function Vuju:attack()
  local damage = self.damage

  -- The Works
  self.target:addBuff('weaken', '.5', 3, self, 'vujuCurse')
  self.attackTimer = self.attackSpeed
end

return Vuju

