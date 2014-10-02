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
	local minions = ctx.target:inRange(self, self.radius, 'minion')
	table.each(minions, function(minion)
		local heal = (not minion.lastSanctuary or minion.lastSanctuary ~= tick) and self.amount or self.amount / 2
		minion.health = math.min(minion.health + heal, minion.maxHealth)
		minion.lastSanctuary = tick
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
