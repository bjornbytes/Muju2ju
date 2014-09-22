Map = class()

Map.width, Map.height = 800, 600

local function drawBackground(self)
  local g = love.graphics
  local p = ctx.players:get(ctx.id)

  g.setColor(255, 255, 255)
  g.draw(data.media.graphics.bg)

  local alpha = ctx.map.spiritAlpha * 255
  alpha = math.lerp(alpha, (1 - (p.healthDisplay / p.maxHealth)) * 255, .5)
  g.setColor(255, 255, 255, alpha)
  g.draw(data.media.graphics.bgSpirit)
end

local function drawForeground(self)
	local g = love.graphics
  local p = ctx.players:get(ctx.id)

	g.setColor(200, 200, 200)
	g.draw(data.media.graphics.grass, 0, 32)

	local alpha = ctx.map.spiritAlpha * 255
	alpha = math.lerp(alpha, (1 - (p.healthDisplay / p.maxHealth)) * 255, .5)
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

  ctx.event:emit('view.register', {object = self.background})
  ctx.event:emit('view.register', {object = self.foreground})
end

function Map:update()
  if ctx.id then
    self.spiritAlpha = math.lerp(self.spiritAlpha, ctx.players:get(ctx.id).dead and 1 or 0, .6 * tickRate)
  end
end
