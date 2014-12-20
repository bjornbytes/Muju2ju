local Frostbite = class()
Frostbite.code = 'frostbite'

function Frostbite:activate()
  ctx.event:emit('view.register', {object = self})
end

function Frostbite:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Frostbite:update()
end

function Frostbite:draw()
	local g = love.graphics
end

return Frostbite
