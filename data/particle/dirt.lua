local Dirt = class()
Dirt.code = 'dirt'

function Dirt:activate()
  self.prevx = self.x
  self.prevy = self.y
	self.vx = love.math.random(-150, 150)
	self.vy = love.math.random(-500, -250)
	self.alpha = .9
	self.size = 1.5 + love.math.random() * 1.5
	self.targety = ctx.map.height - ctx.map.groundHeight + love.math.random(-18, 18)
	self.bounced = love.math.random() > .8
	self.r = 100 + love.math.random(-20, 20)
	self.g = 50 + love.math.random(-10, 10)
	self.b = love.math.random(10)
  ctx.event:emit('view.register', {object = self})
end

function Dirt:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Dirt:update()
  self.prevx = self.x
  self.prevy = self.y
	self.x = self.x + self.vx * tickRate
	if self.vy ~= math.huge then
		self.y = self.y + self.vy * tickRate
		self.vy = self.vy + 1000 * tickRate
		if self.y > self.targety and self.vy > 0 then
			if self.bounced then
				self.vy = math.huge
			else
				self.vy = -self.vy * .5
				self.bounced = true
			end
		end
	else
		self.vx = math.lerp(self.vx, 0, 8 * tickRate)
		if self.vx < 10 then
			self.alpha = math.lerp(self.alpha, 0, 2 * tickRate)
			if self.alpha < .05 then ctx.particles:remove(self) end
		end
	end
end

function Dirt:draw()
	local g = love.graphics
  local x, y = math.lerp(self.prevx, self.x, tickDelta / tickRate), math.lerp(self.prevy, self.y, tickDelta / tickRate)
	g.setColor(self.r, self.g, self.b, 255 * self.alpha)
	g.circle('fill', x, y, self.size)
end

return Dirt
