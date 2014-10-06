local BurstHeal = class()
BurstHeal.code = 'burstHeal'

function BurstHeal:activate()
	self.health = 2 + self.level
	self.maxHealth = self.health
	self.amount = (self.level * 10) * tickRate
	self.depth = 0 + love.math.random()
  ctx.event:emit('view.register', {object = self})
end

function BurstHeal:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function BurstHeal:update()
	local allies = ctx.target:alliesInRange(self, self.radius, 'unit')
	table.each(allies, function(ally)
		local heal = (not ally.lastSanctuary or ally.lastSanctuary ~= tick) and self.amount or self.amount / 2
		ally.health = math.min(ally.health + heal, ally.maxHealth)
		ally.lastSanctuary = tick
	end)
	self.health = timer.rot(self.health, function()
		ctx.spells:remove(self)
	end)
end

function BurstHeal:draw()
	local g = love.graphics
	g.setColor(20, 180, 20, 80 * math.min(self.health / self.maxHealth, 1))
	g.circle('fill', self.x, self.y, self.radius)
end

return BurstHeal
