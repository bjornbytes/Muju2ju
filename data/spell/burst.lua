local Burst = class()
Burst.code = 'burst'

Burst.maxHealth = .5

function Burst:activate()
	self.health = self.maxHealth
	self.angle = love.math.random() * 2 * math.pi
	self.scale = 0
  if self.damage and self.heal then
    self.team = self.owner.team
    table.each(ctx.target:inRange(self, self.radius, 'enemy', 'unit', 'player'), f.ego('hurt', self.damage))
    table.each(ctx.target:inRange(self, self.radius, 'ally', 'unit', 'player'), f.ego('heal', self.heal))
  end
  ctx.event:emit('view.register', {object = self})
end

function Burst:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Burst:update()
	self.health = timer.rot(self.health, function() ctx.spells:remove(self) end)
	self.scale = math.lerp(self.scale, self.radius / 328, 20 * tickRate)
end

function Burst:draw()
	local g = love.graphics
  local image = data.media.graphics.explosion
	g.setColor(230, 40, 40, (self.health / self.maxHealth) * 255)
	g.draw(image, self.x, self.y, self.angle, self.scale + .2, self.scale + .2, image:getWidth() / 2, image:getHeight() / 2)
end

return Burst
