Environment = class()

Environment.depth = 5

function Environment:init()
	self.groundHeight = 92
	self.bg = love.graphics.newImage('media/graphics/bg.png')
	self.bgSpirit = love.graphics.newImage('media/graphics/bgSpirit.png')
	self.spiritAlpha = 0
	ctx.view:register(self)
end

function Environment:update()
	self.spiritAlpha = math.lerp(self.spiritAlpha, ctx.player.dead and 1 or 0, .6 * tickRate)
end

function Environment:draw()
	local g, w, h = love.graphics, love.graphics.getDimensions()
  local bg, bgSpirit = data.media.graphics.bg, data.media.graphics.bgSpirit

	g.setColor(255, 255, 255)
	g.draw(bg)

	local alpha = self.spiritAlpha * 255
	alpha = math.lerp(alpha, (1 - (ctx.player.healthDisplay / ctx.player.maxHealth)) * 255, .5)
	g.setColor(255, 255, 255, alpha)
	g.draw(bgSpirit)
end
