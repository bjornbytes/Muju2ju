local Vuju = extend(Unit)
Vuju.code = 'vuju'

Vuju.width = 48
Vuju.height = 48

Vuju.cost = 20
Vuju.cooldown = 6
Vuju.maxHealth = 70
Vuju.speed = 0

Vuju.damage = 17
Vuju.fireRate = 1.7
Vuju.attackRange = 125

function Vuju:activate()
	Unit.activate(self)

  -- Stats
	self.attackRange = 125
	self.damage = 30

	self.curseRate = 8
	self.curseTimer = 0

  -- Animation
  self.animation = data.animation.vuju(self)
	self.animation.flipX = not self.owner.animation.flipX
end

function Vuju:update()
	if self.animationState == 'death' then -- TODO 'blocking' animations
		self.dead = self.animationState == 'death'
		self.x = self.x + self.knockBack * tickRate * 3000
		self.knockBack = math.max(0, math.abs(self.knockBack) - tickRate) * math.sign(self.knockBack)
		self.knockBackDisplay = math.lerp(self.knockBackDisplay, math.abs(self.knockBack), 20 * tickRate)
		self.offsety = self.y + self.height + 8 - math.abs(self.knockBackDisplay * 200)
		self.animation:update()
		self.healthDisplay = math.lerp(self.healthDisplay, self.health, 20 * tickRate)
		return
	end

	Unit.update(self)

  -- Target Acquired
	self.target = ctx.target:closest(self, 'enemy')
	if self.target and self.fireTimer == 0 and self:inRange() then self:attack() end

  -- Animations
	self.animation.offsety = self.height + 8
	self.animation:update()
end

function Vuju:attack()
  local targets = {self.target}
  local damage = self.damage
  local ox, oy = self.target.x, 0
  local bounces = 0
  for i = 1, math.max(1, 2 * bounces) do
    if i > #targets then break end
    targets[1]:hurt(damage)
    ctx.spells:add('lightning', {x = ox, y = oy, target = targets[1]})
    ox, oy = targets[1].x, targets[1].y
    damage = math.max(damage / 2, self.damage / 4)
    local newTargets = ctx.target:inRange(targets[1], 25 + (25 * bounces), 'enemy')
    if not newTargets then break end
    for j = 1, #newTargets do
      if not table.has(targets, newTargets[j]) then
        table.insert(targets, 1, newTargets[j])
        break
      end
    end
  end

  self.fireTimer = self.fireRate

  self.animation:set('cast')
end

function Vuju:hurt(amount)
	self.health = math.max(self.health - amount, 0)
	if self.health <= 0 then
    self.animation:set('death')
		return true
	end
end

function Vuju:getCost()
  return 12
end

return Vuju
