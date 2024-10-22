Juju = class()

Juju.depth = -6

function Juju:activate()
  self.radius = math.clamp(self.amount / 100, .25, 1) * 48

  if ctx.tag ~= 'server' then
    self.angle = love.math.random() * 2 * math.pi
    self.depth = self.depth + love.math.random()
    self.scale = 0
    self.alpha = 0
    self.prev = {}

    local p = ctx.players:get(ctx.id)
    if p and p.team == self.team then self.amount = self.amount / 2 end
  end

	for i = 1, 15 do
    ctx.event:emit('particles.add', {kind = 'jujuSex', x = self.x, y = self.y})
	end

  ctx.event:emit('view.register', {object = self})
end

function Juju:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Juju:update(noHistory)
  if ctx.tag ~= 'server' then
    self.prev.x = self.x
    self.prev.y = self.y
    self.prev.angle = self.angle
    self.prev.scale = self.scale
    self.prev.alpha = self.alpha
  end

	--[[if self.dead then
		local tx, ty = 52, 52
		self.x, self.y = math.lerp(self.x, tx, 10 * tickRate), math.lerp(self.y, ty, 10 * tickRate)
		self.scale = math.lerp(self.scale, .1, 5 * tickRate)
		if math.distance(self.x, self.y, tx, ty) < 16 then
			ctx.jujus:remove(self.id)
      if ctx.tag == 'server' then
        self.collectedBy.juju = self.collectedBy.juju + self.amount
      end
			for i = 1, 20 do
        ctx.event:emit('particles.add', {kind = 'jujuSex', x = tx, y = ty})
			end
		end
		for i = 1, 2 do
      ctx.event:emit('particles.add', {kind = 'jujuSex', x = self.x, y = self.y})
		end
		return
	end]]
  if self.owner then
    if ctx.tag == 'server' or (self.owner ~= ctx.players:get(ctx.id)) then
      if ctx.tag == 'client' then
        local tx, ty = ctx.view.x + 52, ctx.view.y + 52
        for i = 1, 20 do
          ctx.event:emit('particles.add', {kind = 'jujuSex', x = tx, y = ty})
        end
      end
      self.owner.juju = self.owner.juju + self.amount
      ctx.jujus:remove(self.id)
    else
      local tx, ty = ctx.view.x + 52, ctx.view.y + 52
      self.x, self.y = math.lerp(self.x, tx, 10 * tickRate), math.lerp(self.y, ty, 10 * tickRate)
      self.scale = math.lerp(self.scale, .1, 5 * tickRate)
      if math.distance(self.x, self.y, tx, ty) < 16 then
        ctx.jujus:remove(self.id)
        for i = 1, 20 do
          ctx.event:emit('particles.add', {kind = 'jujuSex', x = tx, y = ty})
        end
      end
      for i = 1, 2 do
        ctx.event:emit('particles.add', {kind = 'jujuSex', x = self.x, y = self.y})
      end
    end

    return
  end

	self.vx = math.lerp(self.vx, 0, tickRate)
	self.vy = math.lerp(self.vy, 0, 2 * tickRate)
	self.x = math.clamp(self.x + self.vx * tickRate, self.radius, ctx.map.width - self.radius)
	self.y = self.y + self.vy * tickRate
	if self.vy > -.1 then self.y = self.y - 10 * tickRate end
  if self.y < -50 then ctx.jujus:remove(self.id) end

  if ctx.tag == 'server' then
    
    -- Lerp'd hit test
    ctx.players:each(function(player)
      if not player.dead then return end
      if math.distance(player.ghostX, player.ghostY, self.x, self.y) < self.radius + player.ghost.radius then
        ctx.net:emit('jujuCollect', {id = self.id, owner = player.id})
      end
    end)
  else

    -- Client side prediction ish test
    local p = ctx.players:get(ctx.id)
    if p and p.dead then
      if math.distance(p.ghostX, p.ghostY, self.x, self.y) < self.radius + p.ghost.radius then
        self.owner = p
      end
    end

    -- Juicy lerps
    self.angle = self.angle + (math.sin(tick * tickRate) * math.cos(tick * tickRate)) / love.math.random(9, 11)
    self.scale = math.lerp(self.scale, self.radius / 48, 2 * tickRate)
    self.alpha = math.lerp(self.alpha, 1, 2 * tickRate)

    -- Passive particles
    if love.math.random() < 2 * tickRate then
      local vx, vy = love.math.random(-100, 100), love.math.random(-100, 100)
      ctx.event:emit('particles.add', {kind = 'jujuSex', x = self.x, y = self.y, vx = vx, vy = vy, alpha = .35})
    end
  end
end

function Juju:draw()
	local g = love.graphics
  local lerpd = table.interpolate(self.prev, self, tickDelta / tickRate)

	local wave = math.sin((tick + tickDelta / tickRate) * tickRate * 4)
  local image = data.media.graphics.juju

	g.setBlendMode('additive')
	g.setColor(255, 255, 255, 30 * lerpd.alpha)
	g.draw(image, lerpd.x, lerpd.y + 5 * wave, lerpd.angle, lerpd.scale * (1.6 + wave / 12), lerpd.scale * (1.6 + wave / 12), image:getWidth() / 2, image:getHeight() / 2)
	g.setBlendMode('alpha')

	g.setColor(255, 255, 255, 255 * lerpd.alpha)
	g.draw(image, lerpd.x, lerpd.y + 5 * wave, lerpd.angle, lerpd.scale, lerpd.scale, image:getWidth() / 2, image:getHeight() / 2)

  --[[g.setFont('inglobalb', 50)
  g.setColor(0, 0, 0, 150 * lerpd.alpha)
  local str = math.round(self.amount)
  g.print(str, lerpd.x, lerpd.y + 5 * wave, 0, lerpd.scale, lerpd.scale, g.getFont():getWidth(str) / 2, g.getFont():getHeight() / 2)]]
end
