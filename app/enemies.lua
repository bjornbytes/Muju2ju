Enemies = extend(Manager)
Enemies.manages = 'enemy'

function Enemies:init()
  Manager.init(self)

	self.level = 0
	self.nextEnemy = 5
	self.minEnemyRate = 6
	self.maxEnemyRate = 9
end

function Enemies:update()
	self.nextEnemy = timer.rot(self.nextEnemy, function()
		if table.count(self.objects) < 1 + self.level / 2 then
			local spawnType
			local x = love.math.random() > .5 and 0 or love.graphics.getWidth()

			spawnType = 'puju'
			if self.maxEnemyRate < 8 then
				if love.math.random() < math.min(8 - self.maxEnemyRate, 2) * .06 then
					spawnType = 'spuju'
				end
			end

			self:add(spawnType, {x = x})
			self.minEnemyRate = math.max(self.minEnemyRate - .055 * math.clamp(self.minEnemyRate / 5, .1, 1), 1.4)
			self.maxEnemyRate = math.max(self.maxEnemyRate - .03 * math.clamp(self.maxEnemyRate / 4, .5, 1), 2.75)
		end
		return self.minEnemyRate + love.math.random() * (self.maxEnemyRate - self.minEnemyRate)
	end)

	if not next(self.objects) and self.level > 1 then
		self.nextEnemy = math.max(.01, math.lerp(self.nextEnemy, 0, .75 * tickRate))
	end

  Manager.update(self)

	self.level = self.level + tickRate / (16 + self.level / 2)
end

function Enemies:remove(enemy)
  Manager.remove(self, enemy)
end
