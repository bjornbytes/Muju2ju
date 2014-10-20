local Wave = {}
Wave.code = 'wave'

function Wave:init()
  self:resize()
	self.strength = {0, 0}
end

function Wave:update()
  local ded = ctx.players:get(ctx.id).dead
	self.strength[1] = math.lerp(self.strength[1], ded and .01 or 0, 6 * tickRate)
	self.strength[2] = math.lerp(self.strength[2], ded and .01 * 4 / 3 or 0, 6 * tickRate)
	self.shader:send('time', tick)
	self.shader:send('strength', self.strength)
end

function Wave:resize()
  self.shader = data.media.shaders.wave
end

return Wave
