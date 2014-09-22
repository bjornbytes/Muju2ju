GhostPlayer = class()

GhostPlayer.radius = 48
GhostPlayer.first = true

function GhostPlayer:init(owner)
  self.owner = owner
	self.x = self.owner.x
	self.y = self.owner.y + self.owner.height
	self.vx = 0
	self.vy = -600
	self.prevx = self.x
	self.prevy = self.y

	self.angle = -math.pi / 2
	self.maxRange = 500

	self.maxDis = math.lerp(self.maxRange, 0, (1 - (self.owner.deathTimer / self.owner.deathDuration)) ^ 3)

  ctx.event:emit('sound.play', {sound = 'spirit', volume = .12})
  ctx.event:emit('view.register', {object = self})
end

function GhostPlayer:update()
	self.prevx = self.x
	self.prevy = self.y

	local scale = math.min(self.owner.deathTimer, 2) / 2
	if self.owner.deathDuration - self.owner.deathTimer < 1 then
		scale = self.owner.deathDuration - self.owner.deathTimer
	end
	scale = .4 + scale * .4
	self.radius = 40 * scale
	
	if ctx.upgrades.muju.diffuse.level == 1 and self.owner.deathTimer < 5 and math.distance(self.x, self.y, px, py) < self.radius * 2 then
		self.owner.deathTimer = math.min(self.owner.deathTimer, .1)
	end
end

function GhostPlayer:draw()
	local g = love.graphics
	local x, y = math.lerp(self.prevx, self.x, tickDelta / tickRate), math.lerp(self.prevy, self.y, tickDelta / tickRate)
  local image = data.media.graphics.spiritMuju

	local scale = math.min(self.owner.deathTimer, 2) / 2
	if self.owner.deathDuration - self.owner.deathTimer < 1 then
		scale = self.owner.deathDuration - self.owner.deathTimer
	end
	scale = .4 + scale * .4
	local alphaScale = math.min(self.owner.deathTimer * 6 / self.owner.deathDuration, 1)
	g.setColor(255, 255, 255, 30 * alphaScale)
	g.draw(image, x, y, self.angle, 1 * scale, 1 * scale, image:getWidth() / 2, image:getHeight() / 2)
	g.setColor(255, 255, 255, 75 * alphaScale)
	g.draw(image, x, y, self.angle, .75 * scale, .75 * scale, image:getWidth() / 2, image:getHeight() / 2)
	g.setColor(255, 255, 255, 200 * alphaScale)
	g.draw(image, x, y, self.angle, .6 * scale, .6 * scale, image:getWidth() / 2, image:getHeight() / 2)

	g.setColor(255, 255, 255, 10)
	g.circle('fill', self.owner.x, self.owner.y + self.owner.height, self.maxDis)
end

function GhostPlayer:move(input)
	local speed = 140 + (28 * ctx.upgrades.muju.zeal.level)
	local px, py = self.owner.x, self.owner.y + self.owner.height
  local x, y = input.x, input.y
  local len = math.distance(0, 0, x, y)
  if len > 0 then
    x = x / len
    y = y / len
  end

  self.vx = math.lerp(self.vx, speed * x, 8 * tickRate)
  self.vy = math.lerp(self.vy, speed * y, 8 * tickRate)
  self.vy = self.vy - 75 * math.max(self.owner.deathTimer - (self.owner.deathDuration - 1), 0) -- initial boost
	self.x = self.x + self.vx * tickRate
	self.y = self.y + self.vy * tickRate

  self.angle = math.anglerp(self.angle, -math.pi / 2 + (math.pi / 7 * (self.vx / speed)), 12 * tickRate)

	self.maxDis = math.lerp(self.maxRange, 0, (1 - (self.owner.deathTimer / self.owner.deathDuration)) ^ 3)
	if math.distance(self.x, self.y, px, py) > self.maxDis then
		local angle = math.direction(px, py, self.x, self.y)
		self.x = math.lerp(self.x, px + math.dx(self.maxDis, angle), 8 * tickRate)
		self.y = math.lerp(self.y, py + math.dy(self.maxDis, angle), 8 * tickRate)
	end

	self.x = math.clamp(self.x, self.radius, ctx.map.width - self.radius)
	self.y = math.clamp(self.y, self.radius, ctx.map.height - self.radius - ctx.map.groundHeight)
end

function GhostPlayer:despawn()
	GhostPlayer.first = false
  ctx.event:emit('view.unregister', {object = self})
end

