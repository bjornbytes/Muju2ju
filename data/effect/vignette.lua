local Vignette = {}
Vignette.code = 'vignette'

function Vignette:init()
  self:resize()
	self.radius = .85
	self.blur = .45
end

function Vignette:update()
	self.blur = math.lerp(self.blur, ctx.players:get(ctx.id).dead and .65 or .45, 6 * tickRate)
	self.shader:send('blur', self.blur)
	self.shader:send('radius', self.radius)
end

function Vignette:resize()
  self.shader = data.media.shaders.vignette
  self.shader:send('frame', {ctx.view.frame.x, ctx.view.frame.y, ctx.view.frame.width, ctx.view.frame.height})
end

return Vignette
