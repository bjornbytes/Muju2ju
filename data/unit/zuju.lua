local Zuju = extend(Unit)
Zuju.code = 'zuju'

Zuju.width = 32
Zuju.height = 48

Zuju.maxHealth = 65
Zuju.maxHealthPerMinute = 7
Zuju.damage = 8
Zuju.damagePerMinute = 13
Zuju.attackRange = 125
Zuju.attackSpeed = 1.5
Zuju.speed = 40

Zuju.arcBounces = 1
Zuju.arcFalloff = .33

Zuju.staticDamage = 10
Zuju.staticDistance = 80
Zuju.staticStun = 1

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
  local targets = {self.target}
  local damage = self.damage
  local ox, oy = self.target.x, 0
  local bounces = 0
  for i = 1, math.max(1, 2 * bounces) do
    if i > #targets then break end
    targets[1]:hurt(damage, self)
    ctx.net:emit('lightning', {kind = 'lightning', x = ox, y = oy, target = targets[1]})
    ox, oy = targets[1].x, targets[1].y
    damage = math.max(damage / 2, self.damage / 4)
    local newTargets = ctx.target:inRange(targets[1], 25 + (25 * bounces), 'enemy', 'unit')
    if not newTargets then break end
    for j = 1, #newTargets do
      if not table.has(targets, newTargets[j]) then
        table.insert(targets, 1, newTargets[j])
        break
      end
    end
  end

  self.attackTimer = self.attackSpeed
end

return Zuju
