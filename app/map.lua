Map = class()

Map.width, Map.height = 1500, 600

local function drawBackground(self)
  local g = love.graphics
  local p = ctx.players:get(ctx.id)

  if not p then return end

  local scale = ctx.map.height / data.media.graphics.bg:getHeight()
  local alpha = ctx.map.spiritAlpha * 255
  alpha = math.lerp(alpha, (1 - (p.healthDisplay / p.maxHealth)) * 255, .5)
  for i = 0, ctx.map.width, data.media.graphics.bg:getWidth() * scale do
    g.setColor(255, 255, 255)
    g.draw(data.media.graphics.bg, i, 0, 0, scale, scale)
    g.setColor(255, 255, 255, alpha)
    g.draw(data.media.graphics.bgSpirit, i, 0, 0, scale, scale)
  end

end

function Map:init()
  self.groundHeight = 92

  self.spiritAlpha = 0

  self.background = {
    depth = 5,
    draw = drawBackground
  }

  if ctx.view then
    ctx.view.xmax = self.width
    ctx.view.ymax = self.height
    ctx.view.x = self.width / 2 - ctx.view.width / 2
  end

  ctx.event:emit('view.register', {object = self.background})
end

function Map:update()
  if ctx.id then
    self.spiritAlpha = math.lerp(self.spiritAlpha, ctx.players:get(ctx.id).dead and 1 or 0, .6 * tickRate)
  end
end
