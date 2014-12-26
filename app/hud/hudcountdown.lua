HudCountdown = class()

local g = love.graphics

function HudCountdown:init()
  self.delay = 0
  self.easeInTimer = 0
  self.easeOutTimer = 0
  self.timer = 0

  self.offset = 0
  self.easeDuration = 1
  self.lepr = Lepr(self, .5, 'inOutBack', {'offset'})
end

function HudCountdown:update()
  self.delay = timer.rot(self.delay, function()
    self.easeInTimer = self.easeDuration
    self.offset = 1
    self.lepr:reset()
  end)

  self.easeInTimer = timer.rot(self.easeInTimer, function()
    self.timer = 5
  end)

  self.easeOutTimer = timer.rot(self.easeOutTimer, function()
    -- game starts
  end)

  self.timer = timer.rot(self.timer, function()
    self.easeOutTimer = self.easeDuration
    self.offset = 0
    self.lepr:reset()
  end)

  self.active = self.delay > 0 or self.easeInTimer > 0 or self.easeOutTimer > 0 or self.timer > 0
end

function HudCountdown:draw()
  local u, v = ctx.hud.u, ctx.hud.v

  self.lepr:update(delta)

  local width = u * .25
  g.setColor(0, 0, 0, 200)
  g.rectangle('fill', (self.offset * width) - width, v * .4, width, v * .2)
  g.rectangle('fill', u - (self.offset * width), v * .4, width, v * .2)

  g.setColor(255, 255, 255)
  g.setFont('mesmerize', .05 * v)

  local str = ctx.config.players[1] and ctx.config.players[1].username
  if str then
    local x, y = math.round((self.offset * width) - width / 2), math.round(v * .5)
    g.printCenter(str, x, y)
  end

  str = ctx.config.players[2] and ctx.config.players[2].username
  if str then
    local x, y = math.round(u - (self.offset * width / 2)), math.round(v * .5)
    g.printCenter(str, x, y)
  end

  if self.timer > 0 then
    local str = math.ceil(self.timer)
    g.print(str, u * .5 - g.getFont():getWidth(str) / 2, v * .5 - g.getFont():getHeight())
  end
end

function HudCountdown:ready()
  self.delay = .5
end
