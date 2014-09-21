local Bloom = {}
Bloom.code = 'bloom'

local g = love.graphics

function Bloom:init()
  self:resize()
	self.alpha = .1
end

function Bloom:update()
  self.alpha = math.lerp(self.alpha, ctx.player.dead and .9 or .1, .6 * tickRate)
end

function Bloom:applyEffect(source, target)
  g.setCanvas(self.canvas)
	g.push()
	g.scale(.25)
	g.draw(source)
	g.pop()
  self.hblur:send('amount', .005)
  self.vblur:send('amount', .005)
  g.setColor(255, 255, 255)
  for i = 1, 6 do
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
  ctx.particles:each(function(particle)
		if particle.code == 'jujuSex' then particle:draw() end
	end)
	local factor = ctx.player.dead and 1 or 1
  love.graphics.setColor(255, 255, 255, self.alpha * 100 * factor)
  g.setBlendMode('additive')
	g.draw(self.canvas, 0, 0, 0, 4, 4)
	local x = ctx.player.dead and math.clamp(ctx.player.ghost.x, 300, 500) or 400
	local y = ctx.player.dead and math.clamp(ctx.player.ghost.y, 0, 600) or 300
	for i = 6, 1, -1 do
		g.draw(self.canvas, x, y, 0, 4 + i * 1.25 * factor, 4 + i * 1.25 * factor, self.canvas:getWidth() / 2, self.canvas:getHeight() / 2)
	end
  g.setBlendMode('alpha')

	if ctx.player.dead then
		ctx.player.ghost:draw()
		ctx.spells:each(function(spell)
      if spell.code == 'juju' then spell:draw() end
    end)
	end

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