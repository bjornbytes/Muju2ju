PlayerServer = extend(Player)

function PlayerServer:activate()
  self.history = {}
  self.ack = tick

  Player.activate(self)
end

function PlayerServer:get(t)
  if t == tick then return self end

  while self.history[1] and self.history[1].tick < tick - 2 / tickRate do
    table.remove(self.history, 1)
  end

  if #self.history == 0 then return self end

  if self.history[#self.history].tick < t then return self end

  for i = #self.history, 1, -1 do
    if self.history[i].tick <= t then return self.history[i] end
  end

  return self.history[1]
end

function PlayerServer:update()
  -- spawn timer decays here and only here, for example
	self.jujuTimer = timer.rot(self.jujuTimer, function()
		self.juju = self.juju + 1
		return 1
	end)

	self:hurt(self.maxHealth * .1 * tickRate)
  self.animation:tick(tickRate)

  Player.update(self)
end

function PlayerServer:getHealthbar()
  return self.x, self.y, self.health / self.maxHealth
end

function PlayerServer:trace(data)
  if data.tick <= self.ack then return end

  self.ack = data.tick

  -- if not self.dead then?
  self:move(data)
  self:slot(data)

  table.insert(self.history, setmetatable({
    x = self.x,
    y = self.y,
    tick = data.tick
  }, self.meta))

  -- sync
  if self.peer then
    local msg = {
      ack = self.ack,
      juju = math.round(self.juju)
    }

    if self.dead then
      msg.ghostX = self.ghostX
      msg.ghostY = self.ghostY
    else
      msg.x = self.x
      msg.health = math.round(self.health)
    end

    ctx.net:send(msgSyncMain, self.peer, msg)
  end

  for i = 1, 2 do
    if i ~= self.id then
      local p = ctx.players:get(i)
      if p and p.peer then
        local animationMap = {
          idle = 1,
          walk = 2,
          summon = 3,
          death = 4,
          resurrect = 5
        }

        local msg = {
          id = self.id,
          tick = tick
        }

        if self.dead then
          msg.ghostX = self.ghostX
          msg.ghostY = self.ghostY

          local angle = math.round(math.deg(self.ghost.angle))
          while angle < 0 do angle = angle + 360 end
          msg.ghostAngle = angle
        else
          msg.x = self.x
          msg.health = math.round(self.health)
          
          local track = self.animation.state:getCurrent(0)
          msg.animationIndex = (track and animationMap[track.animation.name]) or 0
          msg.animationPrev = (track.previous and animationMap[track.previous.animation.name]) or 0
          msg.animationTime = track and track.time or 0
          msg.animationPrevTime = (track.previous and track.previous.time) or 0
          if track.mixDuration == 0 then msg.animationAlpha = 0
          else msg.animationAlpha = math.min(track.mixTime / track.mixDuration * track.mix, 1) end
          msg.animationFlip = self.animation.flipX == true
        end

        ctx.net:send(msgSyncDummy, p.peer, msg)
      end
    end
  end
end

function PlayerServer:spend(amount)
  if self.juju < amount then return false end
  self.juju = self.juju - amount
  return true
end
