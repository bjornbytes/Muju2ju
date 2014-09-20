local Burst = class()
Burst.code = 'burst'

Burst.maxHealth = .5

function Burst:activate()
	self.health = self.maxHealth
	self.angle = love.math.random() * 2 * math.pi
	self.scale = 0
  ctx.view:register(self)
end

function Burst:deactivate()
  ctx.view:unregister(self)
end

function Burst:update()
	self.health = timer.rot(self.health, function() ctx.particles:remove(self) end)
	self.scale = math.lerp(self.scale, self.radius / self.image:getWidth(), 20 * tickRate)
end

function Burst:draw()
	local g = love.graphics
  local image = data.media.graphics.explosion
	g.setColor(230, 40, 40, (self.health / self.maxHealth) * 255)
	g.draw(image, self.x, self.y, self.angle, self.scale + .2, self.scale + .2, image:getWidth() / 2, image:getHeight() / 2)
end

return Burst
