Map = class()

Map.width, Map.height = love.graphics.getDimensions()

local function drawBackground(self)
  local g  = love.graphics

  g.setColor(255, 255, 255)
  g.draw(data.media.graphics.bg)

  local alpha = ctx.map.spiritAlpha * 255
  alpha = math.lerp(alpha, (1 - (ctx.player.healthDisplay / ctx.player.maxHealth)) * 255, .5)
  g.setColor(255, 255, 255, alpha)
  g.draw(data.media.graphics.bgSpirit)
end

local function drawForeground(self)
	local g = love.graphics

	g.setColor(200, 200, 200)
	g.draw(data.media.graphics.grass, 0, 32)

	local alpha = ctx.map.spiritAlpha * 255
	alpha = math.lerp(alpha, (1 - (ctx.player.healthDisplay / ctx.player.maxHealth)) * 255, .5)
	g.setColor(200, 200, 200, alpha)
	g.draw(data.media.graphics.spiritGrass, 0, 32)
end

function Map:init()
  self.groundHeight = 92

  self.spiritAlpha = 0

  self.background = {
    depth = 5,
    draw = drawBackground
  }

  self.foreground = {
    depth = -50,
    draw = drawForeground
  }

 ctx.view:register(self.background)
 ctx.view:register(self.foreground)
end

function Map:update()
	self.spiritAlpha = math.lerp(self.spiritAlpha, ctx.player.dead and 1 or 0, .6 * tickRate)
end
