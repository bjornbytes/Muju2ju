Shrine = class()

Shrine.width = 128 
Shrine.height = 128 

Shrine.maxHealth = 2500

Shrine.depth = 5

function Shrine:init()
	self.x = ctx.map.width / 2
	self.y = ctx.map.height - ctx.map.groundHeight - self.height - 7
	self.health = self.maxHealth
	self.healthDisplay = self.health
	self.color = {255, 255, 255}
	self.highlight = 0

  ctx.event:emit('view.register', {object = self})
end

function Shrine:update()
	if self.health <= 0 then ctx.ded = true end

  if ctx.id then
    local p = ctx.players:get(ctx.id)
    self.color = table.interpolate(self.color, p.dead and {160, 100, 225} or {255, 255, 255}, .6 * tickRate)
    self.healthDisplay = math.lerp(self.healthDisplay, self.health, 20 * tickRate)
    self.highlight = math.lerp(self.highlight, p:atShrine() and 128 or 0, 5 * tickRate)
  end
end

function Shrine:draw()
	local g = love.graphics
  local image = data.media.graphics.shrine

	local scale = self.width / image:getWidth()
	g.setColor(self.color)
	g.draw(image, self.x, self.y + self.height + 12, 0, scale, scale, image:getWidth() / 2, image:getHeight())

	g.setBlendMode('additive')
	g.setColor(255, 255, 255, self.highlight)
	g.draw(image, self.x, self.y + self.height + 12, 0, scale, scale, image:getWidth() / 2, image:getHeight())
	g.setColor(255, 255, 255, 255)
	g.setBlendMode('alpha')
end

function Shrine:hurt(value)
	self.health = self.health - value
	if self.health < 0 then
    ctx.event:emit('sound.play', {sound = 'youlose'})
		if backgroundSound then backgroundSound:stop() end
		return true
	end
end
