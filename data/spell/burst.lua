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
  local damage = 20 * ctx.upgrades.zuju.burst.level
  self.radius = (data.minion.zuju.width / 2) + 50 + 5 * ctx.upgrades.zuju.burst.level
  table.each(ctx.target:inRange(self, self.radius, 'enemy'), f.ego('hurt', damage))
  if math.abs(ctx.player.x - self.x) < self.radius + ctx.player.width / 2 then
    ctx.player:hurt(damage / 2)
  end
  if ctx.upgrades.zuju.sanctuary.level > 0 then
    ctx.spells:add('burstHeal', {x = self.x, y = self.y, radius = self.radius})
  end
end

return Burst

