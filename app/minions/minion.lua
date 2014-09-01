Minion = class()

Minion.width = 48
Minion.height = 48

Minion.depth = -10

function Minion:init(data)
	self.target = nil
	self.fireTimer = 0
	self.y = love.graphics.getHeight() - ctx.environment.groundHeight - self.height

	table.merge(data, self)

	self.maxHealth = self.maxHealth + ctx.upgrades[self.code].fortify * 50 
	self.health = self.maxHealth
	self.healthDisplay = self.health

	ctx.view:register(self)
end

function Minion:update()
	self.timeScale = 1
	self.target = ctx.target:getClosestEnemy(self)
	if self.target ~= ctx.shrine then
		self:attack()
	end
	
	self.fireTimer = self.fireTimer - math.min(self.fireTimer, tickRate * self.timeScale)
	self:hurt(2 * tickRate)
	self.speed = math.max(self.speed - 1 * tickRate, 25)
	self.healthDisplay = math.lerp(self.healthDisplay, self.health, 20 * tickRate)
end

function Minion:attack()
	if self.fireTimer == 0 then		
		if self.target ~= nil then
			local dif = math.abs(self.target.x - self.x)
			if dif <= self.attackRange + self.target.width / 2 then
				local damage = type(self.damage) == 'function' and self:damage() or self.damage

				self.target:hurt(damage)
				self.fireTimer = self.fireRate
				ctx.sound:play({sound = ctx.sounds.combat})
			end
		end
	end
end

function Minion:hurt(amount)
	self.health = self.health - amount
	if self.health <= 0 then
		ctx.minions:remove(self)
		return true
	end
end

function Minion:draw()
	local g = love.graphics

	g.setColor(0, 255, 0, 160)
	g.rectangle('fill', self.x - self.width / 2, self.y, self.width, self.height)

	g.setColor(0, 255, 0)
	g.rectangle('line', self.x - self.width / 2, self.y, self.width, self.height)
end
