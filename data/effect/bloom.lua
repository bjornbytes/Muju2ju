local Bloom = {}
Bloom.code = 'bloom'

local g = love.graphics

function Bloom:init()
  self:resize()
	self.alpha = .1
end

function Bloom:update()
  self.alpha = math.lerp(self.alpha, ctx.players:get(ctx.id).dead and 1 or .5, 6 * tickRate)
end

function Bloom:applyEffect(source, target)
  local p = ctx.players:get(ctx.id)

  g.setColor(255, 255, 255)
  g.setCanvas(self.canvas)
	g.push()
	g.scale(.25)
  g.setShader(self.threshold)
  self.threshold:send('threshold', .75)
	g.draw(source)
	g.pop()
  self.hblur:send('amount', .004)
  self.vblur:send('amount', .004 * (g.getWidth() / g.getHeight()))
  for i = 1, 4 do
    g.setShader(self.hblur)
    self.working:renderTo(function()
      g.draw(self.canvas)
    end)
    g.setShader(self.vblur)
    self.canvas:renderTo(function()
      g.draw(self.working)
    end)
  end

  g.setShader()
  g.setCanvas(target)
  g.draw(source)
  ctx.view:worldPush()
  g.pop()
  local w, h = ctx.view.frame.width, ctx.view.frame.height
  love.graphics.setColor(255, 255, 255, 255 * self.alpha)
  g.setBlendMode('additive')
  g.draw(self.canvas, 0, 0, 0, 4, 4)
  g.setBlendMode('alpha')

  ctx.view:worldPush()
	if p.dead then
		p:draw()
		ctx.jujus:each(f.ego('draw'))
	end
  ctx.particles:each(function(particle)
		if particle.code == 'jujuSex' then particle:draw() end
	end)
  g.pop()

  g.setCanvas()

  self.canvas:clear()
  self.working:clear()
end

function Bloom:resize()
  local w, h = g.getDimensions()
  self.canvas = g.newCanvas(w / 4, h / 4)
  self.working = g.newCanvas(w / 4, h / 4)
	self.threshold = data.media.shaders.threshold
	self.hblur = data.media.shaders.horizontalBlur
	self.vblur = data.media.shaders.verticalBlur
end

return Bloom
