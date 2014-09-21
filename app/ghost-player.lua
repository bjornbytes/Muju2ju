GhostPlayer = class()

GhostPlayer.radius = 48
GhostPlayer.first = true

function GhostPlayer:init()
	self.x = ctx.player.x
	self.y = ctx.player.y + ctx.player.height
	self.vx = 0
	self.vy = -600
	self.magnetRange = 15
	self.prevx = self.x
	self.prevy = self.y

	self.angle = -math.pi / 2
	self.maxRange = 500

	self.maxDis = math.lerp(self.maxRange, 0, (1 - (ctx.player.deathTimer / ctx.player.deathDuration)) ^ 3)

	local sound = ctx.sound:play({sound = 'spirit'})
	if sound then sound:setVolume(.12) end

	ctx.view:register(self)
end

function GhostPlayer:update()
	self.prevx = self.x
	self.prevy = self.y

	local speed = 140 + (28 * ctx.upgrades.muju.zeal.level)
	local px, py = ctx.player.x, ctx.player.y + ctx.player.height
  local x, y = ctx.input:getAxis('x'), ctx.input:getAxis('y')
  local len = math.distance(0, 0, x, y)
  if len > 0 then
    x = x / len
    y = y / len
  end

  self.vx = math.lerp(self.vx, speed * x, 8 * tickRate)
  self.vy = math.lerp(self.vy, speed * y, 8 * tickRate)
  self.vy = vy - 50 * math.max(ctx.player.deathTimer - (ctx.player.deathDuration - 1), 0) -- initial boost
	self.x = self.x + self.vx * tickRate
	self.y = self.y + self.vy * tickRate

  self.angle = math.anglerp(self.angle, -math.pi / 2 + (math.pi / 7 * (self.vx / speed)), 12 * tickRate)

	self.maxDis = math.lerp(self.maxRange, 0, (1 - (ctx.player.deathTimer / ctx.player.deathDuration)) ^ 3)
	if math.distance(self.x, self.y, px, py) > self.maxDis then
		local angle = math.direction(px, py, self.x, self.y)
		self.x = math.lerp(self.x, px + math.dx(self.maxDis, angle), 8 * tickRate)
		self.y = math.lerp(self.y, py + math.dy(self.maxDis, angle), 8 * tickRate)
	end

	self.x = math.clamp(self.x, self.radius, ctx.map.width - self.radius)
	self.y = math.clamp(self.y, self.radius, ctx.map.height - self.radius - ctx.map.groundHeight)

	local scale = math.min(ctx.player.deathTimer, 2) / 2
	if ctx.player.deathDuration - ctx.player.deathTimer < 1 then
		scale = ctx.player.deathDuration - ctx.player.deathTimer
	end
	scale = .4 + scale * .4
	self.radius = 40 * scale
	
	if ctx.upgrades.muju.diffuse.level == 1 and ctx.player.deathTimer < 5 and math.distance(self.x, self.y, px, py) < self.radius * 2 then
		ctx.player.deathTimer = math.min(ctx.player.deathTimer, .1)
	end
end

function GhostPlayer:despawn()
	GhostPlayer.first = false
	ctx.view:unregister(self)
end

function GhostPlayer:draw()
	local g = love.graphics
	local x, y = math.lerp(self.prevx, self.x, tickDelta / tickRate), math.lerp(self.prevy, self.y, tickDelta / tickRate)
  local image = data.media.graphics.spiritMuju

	local scale = math.min(ctx.player.deathTimer, 2) / 2
	if ctx.player.deathDuration - ctx.player.deathTimer < 1 then
		scale = ctx.player.deathDuration - ctx.player.deathTimer
	end
	scale = .4 + scale * .4
	local alphaScale = math.min(ctx.player.deathTimer * 6 / ctx.player.deathDuration, 1)
	g.setColor(255, 255, 255, 30 * alphaScale)
	g.draw(image, x, y, self.angle, 1 * scale, 1 * scale, image:getWidth() / 2, image:getHeight() / 2)
	g.setColor(255, 255, 255, 75 * alphaScale)
	g.draw(image, x, y, self.angle, .75 * scale, .75 * scale, image:getWidth() / 2, image:getHeight() / 2)
	g.setColor(255, 255, 255, 200 * alphaScale)
	g.draw(image, x, y, self.angle, .6 * scale, .6 * scale, image:getWidth() / 2, image:getHeight() / 2)

	g.setColor(255, 255, 255, 10)
	g.circle('fill', ctx.player.x, ctx.player.y + ctx.player.height, self.maxDis)
end
