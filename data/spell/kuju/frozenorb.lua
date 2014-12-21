local FrozenOrb = extend(Spell)
FrozenOrb.code = 'frozenorb'

function FrozenOrb:activate()
  ctx.event:emit('view.register', {object = self})
end

function FrozenOrb:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function FrozenOrb:update()
end

function FrozenOrb:draw()
	local g = love.graphics
  g.setColor(255, 255, 255)
  g.circle('fill', self.x, 10, 10)
end

return FrozenOrb
