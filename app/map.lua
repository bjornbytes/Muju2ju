Map = class()

Map.width, Map.height = 1500, 600
Map.depth = -100

local backgroundData = {
  background = {x = 0, y = 0, depth = 10},
  grassFront1 = {x = 0, y = 837, depth = 0},
  grassFront2 = {x = 1909, y = 827, depth = 0},
  grassMid1 = {x = 783, y = 870, depth = 2},
  grassMid2 = {x = 256, y = 857, depth = 2},
  grassMid3 = {x = 1700, y = 894, depth = 2},
  grassMid4 = {x = 563, y = 850, depth = 4},
  grassMid5 = {x = 2090, y = 858, depth = 4},
}

local function drawBackground(key)
  return function()
    local p = ctx.players:get(ctx.id)
    if not p then return end

    local g = love.graphics
    local image = data.media.graphics.map[key]
    local spirit = data.media.graphics.map[key .. 'Spirit']
    local map = ctx.map
    local scale = ctx.map.height / data.media.graphics.map.background:getHeight()
    local alpha = map.spiritAlpha * 255
    alpha = math.lerp(alpha, (1 - (p.healthDisplay / p.maxHealth)) * 255, .6)

    g.setColor(255, 255, 255)
    g.draw(image, backgroundData[key].x * scale, backgroundData[key].y * scale, 0, scale, scale)
    g.setColor(255, 255, 255, alpha)
    g.draw(spirit, backgroundData[key].x * scale, backgroundData[key].y * scale, 0, scale, scale)
  end
end

function Map:init()
  self.groundHeight = 92

  self.spiritAlpha = 0

  if ctx.view then
    ctx.view.xmax = self.width
    ctx.view.ymax = self.height
    ctx.view.x = self.width / 2 - ctx.view.width / 2
  end
  
  ctx.event:emit('view.register', {object = self})

  local backgrounds = {'background', 'grassFront1', 'grassFront2', 'grassMid1', 'grassMid2', 'grassMid3', 'grassMid4', 'grassMid5'}
  table.each(backgrounds, function(background)
    local object = {
      depth = backgroundData[background].depth,
      draw = drawBackground(background)
    }

    ctx.event:emit('view.register', {object = object})
  end)
end

function Map:draw()
  if ctx.id then
    self.spiritAlpha = math.lerp(self.spiritAlpha, ctx.players:get(ctx.id).dead and 1 or 0, 6 * delta)
  end
end
