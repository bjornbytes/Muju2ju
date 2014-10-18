Ghost = class()

Ghost.radius = 48
Ghost.first = true

function Ghost:init(owner)
  self.owner = owner
  self.active = false
end

function Ghost:activate()
  self.active = true
	self.owner.ghostX = self.owner.x
	self.owner.ghostY = self.owner.y + self.owner.height
  self.drawX = nil
  self.drawY = nil
	self.vx = 0
	self.vy = 0
  self.speed = 140
  self.boost = -650
  self.boosts = {}

  self.health = self.owner.deathDuration
  self.maxHealth = self.health

	self.angle = -math.pi / 2
	self.maxRange = 500

	self.maxDis = math.lerp(self.maxRange, 0, (1 - (self.health / self.maxHealth)) ^ 3)
  self.prevMaxDis = self.maxDis

  ctx.event:emit('sound.play', {sound = 'spirit', volume = .12})
end

function Ghost:deactivate()
  self.active = false
end

function Ghost:update()
	local scale = math.min(self.health, 3) / 2
	if self.maxHealth - self.health < 1 then
		scale = self.maxHealth - self.health
	end
	scale = .4 + scale * .4
	self.radius = 40 * scale

  self.angle = math.anglerp(self.angle, -math.pi / 2 + (math.pi / 7 * (self.vx / self.speed)), 12 * tickRate)

  self.boost = math.lerp(self.boost, 0, 3 * tickRate)
  self.boosts[tick] = self.boost
  self.health = timer.rot(self.health)
  self.prevMaxDis = self.maxDis
  self.maxDis = math.lerp(self.maxRange, 0, (1 - (self.health / self.maxHealth)) ^ 3)
  self:contain()
end

function Ghost:draw(x, y, angle)
	local g = love.graphics
  local image = data.media.graphics.spiritMuju
  angle = angle or self.angle

  if self.drawX and self.drawY then
    local d = math.clamp(math.distance(x, y, self.drawX, self.drawY) / 80, 0, 1)
    x, y = math.lerp(self.drawX, x, d), math.lerp(self.drawY, y, d)
  end

	local scale = math.min(self.health, 2) / 2
	if self.maxHealth - self.health < 1 then
		scale = self.maxHealth - self.health
	end
	scale = .4 + scale * .4
	local alphaScale = math.min(self.health * 6 / self.maxHealth, 1) * (ctx.id == self.owner.id and 1 or .5)
	g.setColor(255, 255, 255, 30 * alphaScale)
	g.draw(image, x, y, angle, 1 * scale, 1 * scale, image:getWidth() / 2, image:getHeight() / 2)
	g.setColor(255, 255, 255, 75 * alphaScale)
	g.draw(image, x, y, angle, .75 * scale, .75 * scale, image:getWidth() / 2, image:getHeight() / 2)
	g.setColor(255, 255, 255, 200 * alphaScale)
	g.draw(image, x, y, angle, .6 * scale, .6 * scale, image:getWidth() / 2, image:getHeight() / 2)

	g.setColor(255, 255, 255, 10)
  local bounds = math.lerp(self.prevMaxDis, self.maxDis, tickDelta / tickRate)
	g.circle('fill', self.owner.x, self.owner.y + self.owner.height, bounds)

  self.drawX, self.drawY = x, y
end

function Ghost:move(input)
	local px, py = self.owner.x, self.owner.y + self.owner.height
  local x, y = input.x, input.y
  local len = math.distance(0, 0, x, y)
  if len > 1 then
    x = x / len
    y = y / len
  end

  self.vx = self.speed * x
  self.vy = self.speed * y
	self.owner.ghostX = self.owner.ghostX + self.vx * tickRate
	self.owner.ghostY = self.owner.ghostY + self.vy * tickRate

	self.owner.ghostX = math.clamp(self.owner.ghostX, self.radius, ctx.map.width - self.radius)
	self.owner.ghostY = math.clamp(self.owner.ghostY, self.radius, ctx.map.height - self.radius - ctx.map.groundHeight)

  local boost = self.boosts[input.tick] or self.boost
  self.owner.ghostY = self.owner.ghostY + boost * tickRate

  self:contain()
end

function Ghost:contain()
  if not self.maxDis then return end
  local px, py = self.owner.x, self.owner.y + self.owner.height
  if math.distance(self.owner.ghostX, self.owner.ghostY, px, py) > self.maxDis then
		local angle = math.direction(px, py, self.owner.ghostX, self.owner.ghostY)
		self.owner.ghostX = math.lerp(self.owner.ghostX, px + math.dx(self.maxDis, angle), 4 * tickRate)
		self.owner.ghostY = math.lerp(self.owner.ghostY, py + math.dy(self.maxDis, angle), 4 * tickRate)
	end
end

function Ghost:contained(t)
  if not self.maxDis then return true end
	local px, py = self.owner.x, self.owner.y + self.owner.height
	return math.distance(self.owner.ghostX, self.owner.ghostY, px, py) < self.maxDis - 20
end

function Ghost:despawn()
	Ghost.first = false
end
