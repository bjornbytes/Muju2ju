local Burst = class()
Burst.code = 'burst'

Burst.maxHealth = .5

function Burst:activate()
	self.health = self.maxHealth
	self.angle = love.math.random() * 2 * math.pi
	self.scale = 0
  self:damage()
  ctx.event:emit('view.register', {object = self})
end

function Burst:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Burst:update()
	self.health = timer.rot(self.health, function() ctx.spells:remove(self) end)
	self.scale = math.lerp(self.scale, self.radius / data.media.graphics.explosion:getWidth(), 20 * tickRate)
end

function Burst:draw()
	local g = love.graphics
  local image = data.media.graphics.explosion
	g.setColor(230, 40, 40, (self.health / self.maxHealth) * 255)
	g.draw(image, self.x, self.y, self.angle, self.scale + .2, self.scale + .2, image:getWidth() / 2, image:getHeight() / 2)
end

function Burst:damage()
  local damage = 20 * self.level
  self.radius = (data.unit.zuju.width / 2) + 50 + 5 * self.level
  table.each(ctx.target:enemiesInRange(self, self.radius, 'enemy', 'player'), f.ego('hurt', damage))
end

return Burst

