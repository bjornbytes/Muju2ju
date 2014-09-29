Ghost = class()

Ghost.radius = 48
Ghost.first = true

function Ghost:init(owner)
  self.owner = owner
	self.x = self.owner.x
	self.y = self.owner.y + self.owner.height
  self.prevx = self.x
  self.prevy = self.y
	self.vx = 0
	self.vy = 0
  self.boost = -750

	self.angle = -math.pi / 2
	self.maxRange = 500

	self.maxDis = math.lerp(self.maxRange, 0, (1 - (self.owner.deathTimer / self.owner.deathDuration)) ^ 3)

  ctx.event:emit('sound.play', {sound = 'spirit', volume = .12})
end

function Ghost:update(dummy)
	local scale = math.min(self.owner.deathTimer, 2) / 2
	if self.owner.deathDuration - self.owner.deathTimer < 1 then
		scale = self.owner.deathDuration - self.owner.deathTimer
	end
	scale = .4 + scale * .4
	self.radius = 40 * scale
	
  if not dummy then
    local speed = 140 + (28 * ctx.upgrades.muju.zeal.level)
    self.angle = math.anglerp(self.angle, -math.pi / 2 + (math.pi / 7 * (self.vx / speed)), 12 * tickRate)

    self.boost = math.lerp(self.boost, 0, 2 * tickRate)
    self.y = self.y + self.boost * tickRate
    self.maxDis = math.lerp(self.maxRange, 0, (1 - (self.owner.deathTimer / self.owner.deathDuration)) ^ 3)
    self:contain()
  end
end

function Ghost:draw()
	local g = love.graphics
  local image = data.media.graphics.spiritMuju
  local x, y = math.lerp(self.prevx, self.x, tickDelta / tickRate), math.lerp(self.prevy, self.y, tickDelta / tickRate)

	local scale = math.min(self.owner.deathTimer, 2) / 2
	if self.owner.deathDuration - self.owner.deathTimer < 1 then
		scale = self.owner.deathDuration - self.owner.deathTimer
	end
	scale = .4 + scale * .4
	local alphaScale = math.min(self.owner.deathTimer * 6 / self.owner.deathDuration, 1) * (ctx.id == self.owner.id and 1 or .5)
	g.setColor(255, 255, 255, 30 * alphaScale)
	g.draw(image, x, y, self.angle, 1 * scale, 1 * scale, image:getWidth() / 2, image:getHeight() / 2)
	g.setColor(255, 255, 255, 75 * alphaScale)
	g.draw(image, x, y, self.angle, .75 * scale, .75 * scale, image:getWidth() / 2, image:getHeight() / 2)
	g.setColor(255, 255, 255, 200 * alphaScale)
	g.draw(image, x, y, self.angle, .6 * scale, .6 * scale, image:getWidth() / 2, image:getHeight() / 2)

	g.setColor(255, 255, 255, 10)
	g.circle('fill', self.owner.x, self.owner.y + self.owner.height, self.maxDis)
end

function Ghost:move(input)
	local speed = 140 + (28 * ctx.upgrades.muju.zeal.level)
	local px, py = self.owner.x, self.owner.y + self.owner.height
  local x, y = input.x, input.y
  local len = math.distance(0, 0, x, y)
  if len > 1 then
    x = x / len
    y = y / len
  end

  self.prevx = self.x
  self.prevy = self.y

  self.vx = speed * x
  self.vy = speed * y
	self.x = self.x + self.vx * tickRate
	self.y = self.y + self.vy * tickRate

	self.x = math.clamp(self.x, self.radius, ctx.map.width - self.radius)
	self.y = math.clamp(self.y, self.radius, ctx.map.height - self.radius - ctx.map.groundHeight)
end

function Ghost:despawn()
	Ghost.first = false
end

function Ghost:contain()
	local px, py = self.owner.x, self.owner.y + self.owner.height

	if math.distance(self.x, self.y, px, py) > self.maxDis then
		local angle = math.direction(px, py, self.x, self.y)
		self.x = px + math.dx(self.maxDis, angle)--math.lerp(self.x, px + math.dx(self.maxDis, angle), 8 * tickRate)
		self.y = py + math.dy(self.maxDis, angle)--math.lerp(self.y, py + math.dy(self.maxDis, angle), 8 * tickRate)
	end
end
